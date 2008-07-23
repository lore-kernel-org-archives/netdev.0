From: "Jon Nelson" <jnelson@jamponi.net>
Subject: Re: [Bugme-new] [Bug 11147] New: tg3 + jumbo frames + scatter-gather == inoperative NIC
Date: Wed, 23 Jul 2008 08:42:40 -0500
Message-ID: <cccedfc60807230642k7dc569c7ta4b2c108139c0d75@mail.gmail.com>
References: <cccedfc60807221838h442e3b8ah8022c07a685ead34@mail.gmail.com>
	 <C27F8246C663564A84BB7AB34397724201E1494B6D@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"jnelson-kernel-bugzilla@jamponi.net"
	<jnelson-kernel-bugzilla@jamponi.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:35965 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbYGWNmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 09:42:42 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1131828fgg.17
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 06:42:41 -0700 (PDT)
In-Reply-To: <C27F8246C663564A84BB7AB34397724201E1494B6D@IRVEXCHCCR01.corp.ad.broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2008 at 1:25 AM, Michael Chan <mchan@broadcom.com> wrote:
> Jon Nelson wrote:
>
>> What other information can I provide?
>> This is 100% reproducible.
>>
>
> Please provide lspci output and tg3 signon output so that
> we know what device is failing.

OK. I added the output of:

{ lspci -t ; lspci -vvv; lspci -k -xxx ; } > lspci-all.frank

as an attachment to the bug.

Also:


frank:~ # ethtool -t eth0
The test result is FAIL
The test extra info:
nvram test     (online)          0
link test      (online)          0
register test  (offline)         1
memory test    (offline)         0
loopback test  (offline)         0
interrupt test (offline)         0

frank:~ #

So, I added the output of:

ethtool -d eth0

Now. The above is all with 1500 byte frames.
If I switch to 9000 byte frames and take the interface down and then
back up again, I am unable to communicate with it, *provided*
scatter-gather is also enabled (which it is by default).

>From a cold boot (and 1500 byte frames):

frank:~ # ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off
frank:~ #

I'll be adding ethtool -d using 9000 byte frames in the next 30 minutes.
Is there anything else I can provide?

-- 
Jon
