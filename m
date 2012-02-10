From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH net-next] drivers/net: Remove boolean comparisons to true/false
Date: Fri, 10 Feb 2012 09:32:39 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E65@saturn3.aculab.com>
References: <1328822243.29329.11.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Joe Perches" <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <1328822243.29329.11.camel@joe2Laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 
> -	u32 func_encode = func |
> -			((is_Pf == true ? 1 : 0) <<
IGU_FID_ENCODE_IS_PF_SHIFT);
> +	u32 func_encode = func | (is_Pf ? 1 : 0) <<
IGU_FID_ENCODE_IS_PF_SHIFT;

This sort of thing is why I personally don't like 'bool' at all.
If 'is_Pf' were an integer type that is known to only contain 0 or 1
then the code can just be:
	u32 func_encode = func | is_Pf << IGU_FID_ENCODE_IS_PF_SHIFT;
although that is still valid when is_Pf is bool, the compiler
is required to generate code on every access that converts
all non-zero values to 1 - so the generated code is likely
to be 'is_Pf ? 1 : 0'.

The generated code is particularly horrid for boolean arithmetic.
IIRC:
   bool_var &= bool_var_1;
typically requires a sequence of compare and branch instructions.

	David


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
