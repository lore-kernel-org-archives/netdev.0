From: TB <lkml@techboom.com>
Subject: Re: [PATCH] tcp_cubic: limit delayed_ack ratio to prevent divide
 error
Date: Fri, 06 May 2011 12:15:46 -0400
Message-ID: <4DC41EB2.6070404@techboom.com>
References: <20110504113351.4643a0c9@nehalam> <16668.1304537481@localhost> <20110504123738.7bb4d1ee@nehalam> <20110504.124053.260068550.davem@davemloft.net> <20110504130456.425dee68@nehalam> <alpine.WNT.2.00.1105041352020.6048@JBRANDEB-DESK2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Sangtae Ha <sangtae.ha@gmail.com>,
	Injong Rhee <injongrhee@gmail.com>,
	"Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>,
	"rdunlap@xenotime.net" <rdunlap@xenotime.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.WNT.2.00.1105041352020.6048@JBRANDEB-DESK2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 11-05-04 04:53 PM, Brandeburg, Jesse wrote:
> 
> 
> On Wed, 4 May 2011, Stephen Hemminger wrote:
> 
>> TCP Cubic keeps a metric that estimates the amount of delayed
>> acknowledgements to use in adjusting the window. If an abnormally
>> large number of packets are acknowledged at once, then the update
>> could wrap and reach zero. This kind of ACK could only
>> happen when there was a large window and huge number of
>> ACK's were lost.
>>
>> This patch limits the value of delayed ack ratio. The choice of 32
>> is just a conservative value since normally it should be range of 
>> 1 to 4 packets.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> patch seems fine, but please credit the reporter (lkml@techboom.com) with 
> reporting the issue with logs, maybe even with Reported-by: and some kind 
> of reference to the panic message or the email thread in the text or 
> header?

We're currently testing the patch on 6 production servers

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBAgAGBQJNxB6yAAoJENOh8x1aI8Ye4ocH/3+6gjWWppgOwql0J4XGGD5R
wJX+u8A+YK2V+GBvxFgQs/qNa3IB/nnWwELolflO80twq2JrOq1I6g2n1VJhHjX4
b5jyROMe2gPHRKESibi84gNIuoImq4bqM/S1u7xWzcikTh8FxCevYQXTNilIKOOf
siuOIypFY7AyqSPjhq5/+HpTrrOQa097PAcVAr8RBO7niyrxAE75ACTolGAKBfvQ
HlOYKmxBT8SbnZ7YJNINopPdtpqz3iaraKWUoT44Wuv8Q8jt0cqB7YJWl0RG/C3y
ABK50Qihl1p6M+LL9jjR2YwVFkjiLyN3fO8g2pjVfn4wh0afFCyWtitN0OFd/4I=
=Vy5E
-----END PGP SIGNATURE-----
