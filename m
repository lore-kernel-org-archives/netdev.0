From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH iproute2 net 3/8] tc/pedit: Introduce 'add' operation
Date: Mon, 24 Apr 2017 10:52:03 +0300
Message-ID: <20170424075203.GA3265@office.localdomain>
References: <20170423125356.1298-1-amir@vadai.me>
 <20170423125356.1298-4-amir@vadai.me>
 <f358025b-2618-3f22-b593-2e4e70fb7a79@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34887 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1166215AbdDXHwH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 03:52:07 -0400
Received: by mail-wm0-f44.google.com with SMTP id w64so54515832wma.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 00:52:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f358025b-2618-3f22-b593-2e4e70fb7a79@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 23, 2017 at 01:44:51PM -0400, Jamal Hadi Salim wrote:
> 
> Thanks for the excellent work.
> 
> On 17-04-23 08:53 AM, Amir Vadai wrote:
> > This command could be useful to increase/decrease fields value.
> > 
> 
> Does this contradict the "retain" feature? Example rule to
> retain the second nibble but set the first to 0xA
> (essentially it X-ORs):
> tc filter add dev lo parent ffff: protocol ip prio 10 \
> u32 match ip dst 127.0.0.1/32 flowid 1:1 \
> action pedit munge offset 0 u8 set 0x0A retain 0xF0

You mean, for example increasing a single nible in an ipv4 address?
If so, then it should work:
# tc filter add dev veth0 parent ffff:  u32 \
    match ip dport 23 0xffff \
		action pedit ex \
		  munge ip src add 1.0.0.0 retain 0xff000000

# tc -s filter show dev veth0 parent ffff:
filter protocol all pref 49151 u32
filter protocol all pref 49151 u32 fh 801: ht divisor 1
filter protocol all pref 49151 u32 fh 801::800 order 2048 key ht 801 bkt 0 terminal flowid ???  (rule hit 0 success 0)
  match 00000017/0000ffff at 20 (success 0 )
	action order 1:  pedit action pass keys 1
 	 index 48 ref 1 bind 1 installed 1 sec used 1 sec
	 key #0  at ipv4+12: add 01000000 mask 00ffffff
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

> 
> Mostly curious about hardware handling.
As to hardware handling, Or did the implementation so he will answer
better. AFAIK, current implementation doesn't allow partial field
setting/adding, so such a rule can't be offloaded. I think it is only to
make things simple and because there was no use case for that.
To my knowledge, hardware should support such thing if needed.

Amir

> 
> cheers,
> jamal
> 
