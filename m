From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Thu, 22 Jan 2004 05:27:47 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040122.052747.15334487.yoshfuji@linux-ipv6.org>
References: <OF1837C6DA.A9CB8829-ON87256E22.006C142B@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: xma@us.ibm.com
In-Reply-To: <OF1837C6DA.A9CB8829-ON87256E22.006C142B@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF1837C6DA.A9CB8829-ON87256E22.006C142B@us.ibm.com> (at Wed, 21 Jan 2004 11:45:30 -0800), Shirley Ma <xma@us.ibm.com> says:

> > So I'm going to let this sit for another day or two so people can voice
> any
> objections they may have.
> 
> Did you hear different voices? If not could you please check in this patch?

I'm not against holding in u64, 
but I rebember that Linus did not liked that.
Is it okay?

BTW,

diff -urN linux-2.6.1/net/ipv6/proc.c linux-2.6.1-ipv6mib2-64/net/ipv6/proc.c
:
 struct snmp6_item
 {
        char *name;
+       int   size;
        int   offset;
 };
:
+               if (size == 4) {
+                       res += *((__u32 *)
+                               (((void *)per_cpu_ptr(mib[0], i)) + offt));
+                       res += *((__u32 *)
+                               (((void *)per_cpu_ptr(mib[1], i)) + offt));
+               } else if (size == 8) {
+                       res += *((__u64 *)
+                               (((void *)per_cpu_ptr(mib[0], i)) + offt));
+                       res += *((__u32 *)
                                  ~~~~~__u64?
+                               (((void *)per_cpu_ptr(mib[1], i)) + offt));
+               }

I don't understand who really requires the "size" field.
The size is always 8, isn't it?
Am I missing sonething?

I'd prefer:
		if (size == sizeof(u32)) {
			:
                } else if (size == sizeof(u64) {
		        :
		}

> I am going to submit another patch about new IPv6 MIBs system & interface
> statistics counters for your review, which depends on this one.

Please be sure not to change the interface when you submit the next patch.

--yoshfuji
