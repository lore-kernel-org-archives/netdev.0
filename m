From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH netdev-2.6 8/10] ixgb: Ethtool_ops support
Date: Fri, 29 Oct 2004 08:25:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <418260FB.4080807@osdl.org>
References: <Pine.LNX.4.44.0410290500450.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0410290500450.26064-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> +	
> +	if(netif_running(adapter->netdev)) {
>  		ixgb_down(adapter, TRUE);
> +		ixgb_reset(adapter);
>  		ixgb_up(adapter);
> -	}

_Many_ cases where "if(" should be "if (" (same for "for").

 > +static int
 > +ixgb_get_regs_len(struct net_device *netdev)
 > +{
 > +#define IXGB_REG_DUMP_LEN  136*sizeof(uint32_t)
 > +	return IXGB_REG_DUMP_LEN;
 > +}

Might as well #undef this constant if you want it to be "local".


There are several places where an if () also does an assignment
without doing a comparison.  sparse will beep/gong on those.
Have you tried sparse?  E.g.:
+		if((err = ixgb_up(adapter)))
+			return err;
Instead of using double parens to appease gcc, do this:
		if ((err = ixgb_up(adapter) != 0)
			return err;


-- 
~Randy
