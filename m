From: Dave Hansen <haveblue@us.ibm.com>
Subject: RE: e1000 performance hack for ppc64 (Power4)
Date: 13 Jun 2003 09:21:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1055521263.3531.2055.camel@nighthawk>
References: <OF0078342A.E131D4B1-ON85256D44.0051F7C0@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>, David Gibson <dwg@au1.ibm.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Anton Blanchard <anton@samba.org>, Nancy J Milliner <milliner@us.ibm.com>,
   Ricardo C Gonzalez <ricardoz@us.ibm.com>,
   Brian Twichell <twichell@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herman Dierks <hdierks@us.ibm.com>
In-Reply-To: <OF0078342A.E131D4B1-ON85256D44.0051F7C0@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Too long to quote:
http://marc.theaimsgroup.com/?t=105538879600001&r=1&w=2

Wouldn't you get most of the benefit from copying that stuff around in
the driver if you allocated the skb->data aligned in the first place? 

There's already code to align them on CPU cache boundaries:
#define SKB_DATA_ALIGN(X)       (((X) + (SMP_CACHE_BYTES - 1)) & \
                                 ~(SMP_CACHE_BYTES - 1))

So, do something like this:
#ifdef ARCH_ALIGN_SKB_BYTES
#define SKB_ALIGN_BYTES ARCH_ALIGN_SKB_BYTES
#else
#define SKB_ALIGN_BYTES SMP_CACHE_BYTES
#endif
#define SKB_DATA_ALIGN(X)       (((X) + (ARCH_ALIGN_SKB - 1)) & \
                                 ~(SKB_ALIGN_BYTES - 1))

You could easily make this adaptive to no align on th arch size when the
request is bigger than that, just like in the e1000 patch you posted.  
-- 
Dave Hansen
haveblue@us.ibm.com
