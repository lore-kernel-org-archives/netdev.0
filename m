From: David Gundersen <gundy@iinet.net.au>
Subject: Re: r8169 tx problem (1s pause with ping)
Date: Fri, 15 Jun 2007 01:33:14 +1000
Message-ID: <46715FBA.3070302@iinet.net.au>
References: <20070613004154.GA4187@kvack.org> <20070613211859.GA22521@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070901090103090203050602"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from customer-domains.icp-qv1-irony14.iinet.net.au ([203.59.1.169]:4392
	"EHLO customer-domains.icp-qv1-irony14.iinet.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752618AbXFNPc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 11:32:57 -0400
In-Reply-To: <20070613211859.GA22521@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070901090103090203050602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Francois Romieu wrote:
> Benjamin LaHaise <bcrl@kvack.org> :
> [...]
>> I'm seeing something odd with r8169 on FC7: doing a ping -s 1600 alternates 
>> between a 1s latency and sub 1ms.  Has anyone else seen anything like this?  
>> The system in question is an Asus M2A-VM with an onboard RTL8111 (I think).  
>> NAPI doesn't seem to make a difference.  The kernel in question is currently 
>> a vanilla 2.6.21.5.  Sub-mtu sized packets behave normally.
> 
> Same thing here for my 8168 rev 01 (asrock 945G dvi LOM) with 2.6.22-rc4
> and 2.6.22-rc3 + r816x patchkit.
> 
> Wonderful.
> 

I've got a modified version of the latest realtek (r8168) driver running 
here that doesn't seem to exhibit those symptoms.

The trouble I have is that I've been playing with multiple sections of 
the code and I'm not 100% sure what part(s) might impact that particular 
test.  The bits I know I've messed with are the bits that set the 
First/Last fragment flags and the NPQ flagging section (as described in 
my previous emails).

I know it's not particularly scientific of me to be changing multiple 
sections of the driver at once and I'm sorry about that but it's fairly 
late here and I really should get some sleep :).  I might do some more 
thorough testing on the weekend to find out what the minimal changes 
required are to get things working.

In the mean-time I'll attach my patch for the r8168-8.001.00 realtek 
driver here in case anybody else wants to have a play with it and see if 
it helps them out.

Also, It might be a silly question, but have you tried taking packet 
captures from the perspective of the box with the realtek chipset & 
another box during the pinging and comparing the two?

Regards,
Dave.

--------------070901090103090203050602
Content-Type: application/x-gzip;
 name="r8168-8.001.00-dg.patch.gz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="r8168-8.001.00-dg.patch.gz"

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
R/mEDiU1kv+iRtb+4Ow/qz6QsIoTAAA=
--------------070901090103090203050602--
