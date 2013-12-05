From: Michael Tuexen <Michael.Tuexen@lurchi.franken.de>
Subject: Re: Supporting 4 way connections in LKSCTP
Date: Thu, 5 Dec 2013 14:07:41 +0100
Message-ID: <E816D349-2DE7-4F28-9297-F212ED4C6935@lurchi.franken.de>
References: <CAFXGft+CXk3W8=3w=AuYzqYtYnR8nH4Of9=668tUeT+tugD9-A@mail.gmail.com>	<CAFXGftJQV=5Pqs3bhfiS3T1VO1q8jfaMjAUiqm2tDbtSyBCM3A@mail.gmail.com>	<529C9B50.50002@gmail.com>	<CAGugRbXFirQ5P3ek9zN86h4vvO6qsy3eNEooJOApotA+dL+C_g@mail.gmail.com>	<529CB859.9090904@gmail.com>	<CAFXGft+F52p+oaa59=5e5pGfON44N36NA-XMYi5PorzWeybnKw@mail.gmail.com>	<CAFXGft+4o6fT4SYbu3musC+-BEi=xOEGUbZSavF1-0_V1mg6zg@mail.gmail.com>	<529D3BF9.3070208@gmail.com>	<CAFXGftJtCCJ=pVxg_DH-+n2bKmoKXavog0y8mfX+h-1z3hP49Q@mail.gmail.com>	<529DCF42.1070800@gmail.com>	<CAFXGftK5tz90OzObiV7Hi+g080j3zWCNdo217CKdNkOY4JWQUg@mail.gmail.com>	<529DF73E.7060604@gmail.com> <CAFXGftKZD0zN1S=UTa_bYr71-v=7mzU=_CewTNkjPv9CGGB_Fg@mail.gmail.com> <529F395B.9040308@gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B745D@saturn3.aculab.com> <5
 29F4D1A.3050304@gmail.com> <7A4B9BD9-B2BF-4625-A2E5-500CD4A6D399@lurchi.franken.de> <529F5472.9030207@gmail.com> <4F0BC498-2F09-4DB6-83DC-82571645476B@lurchi.franken.de> <529F7336.1000007@gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7460@saturn3.aculab.com>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Vlad Yasevich" <vyasevich@gmail.com>,
	"Sun Paul" <paulrbk@gmail.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>, "Karl Heiss" <kheiss@gmail.com>,
	"Neil Horman" <nhorman@tuxdriver.com>,
	<linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7460@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Dec 5, 2013, at 10:35 AM, David Laight <David.Laight@ACULAB.COM> wrote:

>>>> the configured addresses could be:
>>>> System A) 10.0.0.1 on Lan X, 10.10.0.1 on Lan Y
>>>> System B) 10.0.0.2 on Lan X, 10.10.0.2 on Lan Y
>>>> System C) 10.0.0.3 on Lan X, 10.10.0.2 on Lan Z
>>>> 
>>>> Same problem will occur.
> ...
>> With that, Sys A talking to Sys C will get an abort
>> from Sys B when trying to talk to 10.10.0.2.  With /8, it'll be
>> even worse since SysB and SysC will have duplicate addresses
>> within the subnet. :)
>> 
>> The point is that you don't always know that the same private subnet
>> is in reality 2 different subnets with duplicate addresses.
>> 
>> I've had to debug an actual production issue similar to this where
>> customer had a very similar configuration to above, and their
>> associations kept getting aborted.  When I tried accessing the
>> system that kept sending aborts, I found it was some windows
>> server and not a Diameter station they were expecting.
> 
> Does seem that the addresses listed in INIT and INIT_ACK chunks
> should be ignored until a valid HB response has been received.
You are not allowed to send DATA to them until they are confirmed.
> If an abort is received before a valid HB response then the
> address should be ignored rather than the connection aborted.
No.
> Then it wouldn't matter anywhere near as much if addresses are
> advertised that are not reachable from the remote system.
> 
> All this should have been thought about when the original RFC
> was written.
Scoping wasn't considered that much, same as NAT traversal.
The assumption was that in SIGTRAN networks no NAT boxes are
deployed and you use appropriate addressing (for redundancy).

Best regards
Michael
> 
> 	David
> 
> 
> 
> 
