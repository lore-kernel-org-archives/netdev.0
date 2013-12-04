From: Michael Tuexen <Michael.Tuexen@lurchi.franken.de>
Subject: Re: Supporting 4 way connections in LKSCTP
Date: Wed, 4 Dec 2013 18:06:41 +0100
Message-ID: <32BF466D-E562-480D-8897-63286F90CCC1@lurchi.franken.de>
References: <CAFXGft+CXk3W8=3w=AuYzqYtYnR8nH4Of9=668tUeT+tugD9-A@mail.gmail.com>	<20131127124530.GA23369@hmsreliant.think-freely.org>	<CAFXGftJQV=5Pqs3bhfiS3T1VO1q8jfaMjAUiqm2tDbtSyBCM3A@mail.gmail.com>	<529C9B50.50002@gmail.com>	<CAGugRbXFirQ5P3ek9zN86h4vvO6qsy3eNEooJOApotA+dL+C_g@mail.gmail.com>	<529CB859.9090904@gmail.com>	<CAFXGft+F52p+oaa59=5e5pGfON44N36NA-XMYi5PorzWeybnKw@mail.gmail.com>	<CAFXGft+4o6fT4SYbu3musC+-BEi=xOEGUbZSavF1-0_V1mg6zg@mail.gmail.com>	<529D3BF9.3070208@gmail.com>	<CAFXGftJtCCJ=pVxg_DH-+n2bKmoKXavog0y8mfX+h-1z3hP49Q@mail.gmail.com>	<529DCF42.1070800@gmail.com>	<CAFXGftK5tz90OzObiV7Hi+g080j3zWCNdo217CKdNkOY4JWQUg@mail.gmail.com>	<529DF73E.7060604@gmail.com> <CAFXGftKZD0zN1S=UTa_bYr71-v=7mzU=_CewTNkjPv9CGGB_Fg@mail.gmail.com> <529F395B.9040308@gmail.com> <AE90C24D6B
 3A694183C094C60CF0A2F6026B745D@saturn3.aculab.com> <529F4D1A.3050304@gmail.com> <7A4B9BD9-B2BF-4625-A2E5-500CD4A6D399@lurchi.franken.de> <529F5472.9030207@gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B745F@saturn3.aculab.com>
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
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B745F@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Dec 4, 2013, at 5:48 PM, David Laight <David.Laight@ACULAB.COM> wrote:

>> The point is that address scoping should be used. When sending an
>> INIT from 10.10.10.1 to 10.10.10.4 you should not list 192.168.1.1,
>> since you are transmitting an address to a node which might or might
>> not "be in the same scope".
> 
> You might have two machines that are connected via the public
> internet and also via a private network.
> The two sets of cabling being completely separate giving you
> resilience to network failure.
> In which case you definitely don't want address scoping.
Well, if you give the SCTP stack a hint when initiating
the association, it can do the right thing.
Calling sctp_connect(private_address) should work. It will list
the public address without any problems.
One can debate that sctp_connectx(private_address, public_address)
will result in sending an INIT to the public_address listing the
private one. However, calling sctp_connect(public_address) should
not list the private_address.

Best regards
Michael
> 
> While you may not want the SCTP traffic on the public network
> itself, it could easily be routed separately.
> 
> We have systems that 'sort of' designate one interface for SIP/RTP
> and the other for 'management'. They might run M3UA/SCTP but no one
> has really thought enough about which interface(s) the M3UA traffic
> should use.
> (Think of an ISUP/SIP gateway using M3UA for ISUP signalling.)
> 
> 	David
> 
> 
> 
> 
