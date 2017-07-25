From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Tue, 25 Jul 2017 13:14:26 -0500
Message-ID: <04e3986b-bbeb-50ad-30e0-fb74bb534aa6@ti.com>
References: <20170724230521.1436-1-fcooper@ti.com>
 <20170724230521.1436-3-fcooper@ti.com>
 <29df7e04-01c6-a09b-491e-1354dab98cd0@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        <dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <29df7e04-01c6-a09b-491e-1354dab98cd0-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 07/25/2017 11:32 AM, Oliver Hartkopp wrote:
> 
>> + max-data-speed:    a positive non 0 value that determines the max
>> data rate
>> +            that can be used in CAN-FD mode. A value of -1 implies
>> +            CAN-FD is not supported by the transceiver.
>> +
>> +Examples:
> 
> (..)
> 
>> +    fixed-transceiver {
>> +        max-data-speed = <(-1)>;
> 
> Looks ugly IMHO.
> 
> Why didn't you stay on '0' for 'not supported'??

Unless a driver specifically calls of_can_transceiver_fixed
priv->max_trans_data_speed will be by default 0. Therefore, all drivers
that support CAN-FD will claim that the transceiver indicates that it
isn't supported. So one option was to update every single driver to set
this property by default which I started to do but it end up becoming a
massive patch and it was risky in case I missed a driver which would of
resulted in major regressions. Its also problematic for new drivers that
miss this property or the many out of tree CAN drivers. The other option
was to create another variable to track to see if
of_can_transceiver_fixed was called but I didn't think that was the
better solution. So using signed values in DT is a bit ugly due to
syntax but was valid and I made sure I documented it so its clear.
> 
> Regards,
> Oliver
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
