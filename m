From: Neil Jerram <Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org>
Subject: Re: [patch net-next RFC v2 2/6] skbuff: add "missed_flow"
	flag
Date: Mon, 31 Mar 2014 20:39:06 +0000
Message-ID: <F6885DC5CBE92C4BB4D654841E63A30FD7DFC900@ENFIRHMBX1.datcon.co.uk>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <1395851472-10524-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 "andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org" <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 "f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 "jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 "ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org" <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 "roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org" <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 "jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org" <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
 "linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 "vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 "sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org" <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
 "dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: 'Jiri Pirko' <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
 <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395851472-10524-3-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 03db95a..0100c2f 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -567,6 +567,7 @@ struct sk_buff {
>  	 * headers if needed
>  	 */
>  	__u8			encapsulation:1;
> +	__u8			missed_flow:1;
>  	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
>  	kmemcheck_bitfield_end(flags2);

Presumably you need to update the "6/8 bit hole" comment here.

Regards,
	Neil
