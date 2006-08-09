From: Arnd Bergmann <arnd.bergmann@de.ibm.com>
Subject: Re: [PATCH 4/6] ehea: header files
Date: Wed, 9 Aug 2006 15:17:36 +0200
Message-ID: <200608091517.37379.arnd.bergmann@de.ibm.com>
References: <44D99F56.7010201@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:12748 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750763AbWHINRk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 09:17:40 -0400
To: linuxppc-dev@ozlabs.org
In-Reply-To: <44D99F56.7010201@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 August 2006 10:39, Jan-Bernd Themann wrote:
> +extern int ehea_trace_level;
> +
> +#ifdef EHEA_NO_EDEB
> +#define EDEB_P_GENERIC(level, idstring, format, args...) \
> +=A0=A0=A0=A0=A0=A0=A0while (0 =3D=3D 1) { \
> +=A0=A0=A0=A0=A0=A0=A0 =A0 =A0if(unlikely (level <=3D ehea_trace_leve=
l)) { \
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
printk("%s " idstring " "format "\n", \
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0__func__, ##args); \
> +=A0=A0=A0=A0=A0=A0=A0 =A0} \
> +=A0=A0=A0=A0=A0=A0=A0} \
> +
> +#else
> +
> +#define EDEB_P_GENERIC(level,idstring,format,args...) \
> +if (level < KEEP_EDEBS_BELOW) { \
> +=A0=A0=A0=A0=A0=A0=A0do { \
> +=A0=A0=A0=A0=A0=A0=A0 =A0 =A0if(unlikely (level <=3D ehea_trace_leve=
l)) { \
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
printk("%s " idstring " "format "\n", \
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0__func__, ##args); \
> +=A0=A0=A0=A0=A0=A0=A0 =A0} \
> +=A0=A0=A0=A0=A0=A0=A0} while (1 =3D=3D 0); \
> +}
> +#endif
> +
> +#define EDEB(level, format, args...) \
> + =A0 =A0 =A0 =A0EDEB_P_GENERIC(level, "", format, ##args)
> +
> +#define EDEB_ERR(level, format, args...) \
> + =A0 =A0 =A0 =A0EDEB_P_GENERIC(level, "EHEA_ERROR", format, ##args)
> +
> +#define EDEB_EN(level, format, args...) \
> + =A0 =A0 =A0 =A0EDEB_P_GENERIC(level, ">>>", format, ##args)
> +
> +#define EDEB_EX(level, format, args...) \
> + =A0 =A0 =A0 =A0EDEB_P_GENERIC(level, "<<<", format, ##args)

Please don't invent your own debugging macros. You can either use the
pr_debug/pr_info facility from <linux/kernel.h> or get rid of those
completely. The latter is probably preferred for most of your calls.

	Arnd <><
