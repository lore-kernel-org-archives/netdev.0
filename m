From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute PATCH 06/12] man: Add a man page for the police action
Date: Mon, 7 Mar 2016 07:23:01 -0500
Message-ID: <56DD72A5.9030309@mojatatu.com>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
 <1457093507-25601-7-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34729 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbcCGMXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 07:23:04 -0500
Received: by mail-ig0-f177.google.com with SMTP id ir4so46282966igb.1
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 04:23:03 -0800 (PST)
In-Reply-To: <1457093507-25601-7-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-04 07:11 AM, Phil Sutter wrote:
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>   man/man8/tc-police.8 | 127 +++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 127 insertions(+)
>   create mode 100644 man/man8/tc-police.8
>
> diff --git a/man/man8/tc-police.8 b/man/man8/tc-police.8
> new file mode 100644
> index 0000000000000..2b1537ec52875
> --- /dev/null
> +++ b/man/man8/tc-police.8
> @@ -0,0 +1,127 @@

There are two approaches to measuring the rate and therefore
two algorithms. One uses the dual token bucket and is mostly
what you describe. The other uses a sampling technique;
you sort of glossed over that. They probably should have
been separate actions (I would have called this one
ewmapolice).

Here's an example:
----
REMOTEIP="10.0.0.13" # IP address of remote host
TC="sudo /sbin/tc"
# policer to allow average rate of 1Mbit bandwith estimated by $EST
AVRATE="avrate 10kbit"
EST="estimator 1sec 2sec" # sample 1 sec, average every 2 secs

$TC qdisc add dev $ETH ingress


$TC filter add dev $ETH parent ffff: pref 11 \
$EST protocol ip u32 match ip src $REMOTEIP flowid 1:1 \
action police $AVRATE conform-exceed drop/pipe
----

Essentially this says to use a sampling frequency of 1sec with
a smoothing frequency of 2secs and an average rate of 1Mbps.

cheers,
jamal
