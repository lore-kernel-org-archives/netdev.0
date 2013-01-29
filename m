From: rapier <rapier@psc.edu>
Subject: Re: [Web10g-user] Web10g TCP statistics patch - mainlining into kernel?
Date: Tue, 29 Jan 2013 14:34:04 -0500
Message-ID: <5108242C.1050109@psc.edu>
References: <18855.1359138716@turing-police.cc.vt.edu> <1359481755.4144.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, netdev@vger.kernel.org,
	web10g-user@web10g.org, linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359481755.4144.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/29/13 12:49 PM, Ben Hutchings wrote:
> On Fri, 2013-01-25 at 13:31 -0500, Valdis Kletnieks wrote:
> [...]
>> it's a zero-hit thing for people who don't choose to configure
>> it into their kernel.
> [...]
>
> People with high-overhead changes always say this, but before long
> distributions will be expected to enable it and then everyone pays the
> price.  So I think you'll have to work on limiting the run-time overhead
> when it's enabled at compile time but the user doesn't care about it.
> Possibly it can be a run-time option?  (I haven't looked at the code and
> don't expect to have time to do so.)

I should point out that Web10G is two stage solution. The first is the 
incorporation of the kernel instrument set (KIS, RFC 4898) into the 
stack. This is a pretty straightforward process where (basically) 
counters are incremented based on the existing events within the stack. 
At this point the data is still in kernel space. To move it up to the 
user we rely on a DKLM ABI based on netlink/genetlink. Since the ABI 
isn't loaded by default the question that the Web10G team is working on 
is how to quantify what sort of overhead the KIS actually imposes. We 
hope to have this information available to the community in the next month.

It's our hope that the KIS has negligible impact making it suitable for 
inclusion. The last thing we want to do is impact the performance of the 
kernel in production environments. The admin can choose to load the DKLM 
at their discretion. We'll be quantifying the impact a loaded DKLM has 
so people can make informed choices about this. As a note, since the KIS 
and the ABI are discrete components anyone could build a more efficient 
ABI once the KIS exists. At this time we are basically just looking at 
how to implement RFC4898 in a way that makes sense to the community as a 
whole.

Chris Rapier
