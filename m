From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Fri, 20 Nov 2015 23:45:34 +0100
Message-ID: <20151120224534.GA25025@electric-eye.fr.zoreil.com>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
 <20151118050919.GR25216@marvin.atrad.com.au>
 <20151119005608.GB4882@electric-eye.fr.zoreil.com>
 <20151120024616.GL7136@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Woithe <jwoithe@atrad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33877 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934963AbbKTWpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 17:45:43 -0500
Content-Disposition: inline
In-Reply-To: <20151120024616.GL7136@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Woithe <jwoithe@atrad.com.au> :
[...]
> This indicates to me that in the fault condition, packets coming into the PC
> are being held by the lower layers (perhaps even the hardware) for a very
> long time, and in fact only seem to be released once a packet is queued for
> transmission.
> 
> I then ran a test using the capture script you suggested.  For this test I
> arranged to only send the C-A packet sequence repeatedly until an error
> condition was detected.  Approximate times of the sequence's start time and
> the outcome of the sequence were:
> 
>   1447985720: C response received, A response received
>   1447985722: C response received, A response was not seen(*)
>   1447985739: C response received, A response received
> 
> (*) Based on the earlier test, I expect it was delivered to the OS layer at
> the start of the next test, when the "C" packet was sent.

The register dumps all look the same. Nothing to see here.

The hardware stats are not exactly clear. Is the initial Tx - Rx packet
difference (6) at the hardware stats level expected ?

                            ! late Tx burp
  272 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-++-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      +         +         +         +        +         ***************     +
  270 +Tx *******+....................................*..................+-+
      |Rx #######         :         :        :        *:         :         |
      |         :         : ************************** :         :         |
  268 +-+..................*.............................................+-+
      |         :     *****         :        :         :         :         |
  266 +-+............*...................................................+-+
      |         : ***     :         :        :         :         :         |
  264 +-+........*.....................................###############...+-+
      |         :*        :         :        :        #:         :         |
      ***********         :         :        :        #:         :         |
  262 +-+..................###########################...................+-+
      |         :     #####         :        :         :         :         |
  260 +-+............#...................................................+-+
      |         : ###     :         :        :         :         :         |
      |         :#        :         :        :         :         :         |
  258 +-+........#.......................................................+-+
      ###########         +         +        +         +         +         +
  256 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-++-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    15:15     15:20     15:25     15:30    15:35     15:40     15:45     15:50


                     Tx  Rx
1447985715.230668398 263 257
1447985716.234480645 263 257
1447985717.238563603 263 257
1447985718.242506424 263 257
1447985719.246230757 263 257
1447985720.249900368 263 257
1447985721.253727549 265 259
1447985722.257578916 265 259
1447985723.261457073 267 261
1447985724.264998842 267 261
1447985725.268928099 267 261
1447985726.272550987 269 262
1447985727.277086547 269 262
1447985728.280609761 269 262
1447985729.284707715 269 262
1447985730.288299143 269 262
1447985731.292144772 269 262
1447985732.295803667 269 262
1447985733.299568961 269 262
1447985734.303204633 269 262
1447985735.307015920 269 262
1447985736.310640604 269 262
1447985737.314153757 269 262
1447985738.318170685 269 262
1447985739.322196876 269 262
1447985740.325972075 271 264
1447985741.330118113 271 264
1447985742.334009017 271 264
1447985743.337646906 271 264
1447985744.341710301 271 264
1447985745.345781415 271 264
1447985746.349656916 271 264
1447985747.353606904 271 264

-- 
Ueimor
