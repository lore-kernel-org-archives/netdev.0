From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/7] rtlwifi: Neaten RT_ASSERT, RT_TRACE, RTPRINT, RT_PRINT_DATA macros
Date: Thu, 5 Jan 2012 11:25:30 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF30@saturn3.aculab.com>
References: <54d3f83c3e53d7008a013a631c23360a983695a6.1325734202.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>,
	"Larry Finger" <Larry.Finger@lwfinger.net>,
	"Chaoming Li" <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42254 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755542Ab2AEL1Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 06:27:16 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16087-05 for <netdev@vger.kernel.org>;
 Thu,  5 Jan 2012 11:27:12 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <54d3f83c3e53d7008a013a631c23360a983695a6.1325734202.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define RT_PRINT_DATA(rtlpriv, _comp, _level, _titlestring, _hexdata,
\
> +		      _hexdatalen)			 	\
> +do {							 	\
> +	if (unlikely(((_comp) & rtlpriv->dbg.global_debugcomponents) &&
\
> +		     (_level <= rtlpriv->dbg.global_debuglevel))) {
\
> +		printk(KERN_DEBUG "%s: ", KBUILD_MODNAME); 	\
> +		pr_cont("In process \"%s\" (pid %i):",	 	\
> +			current->comm, current->pid);	 	\
> +		printk(_titlestring);			 	\
> +		print_hex_dump_bytes("", DUMP_PREFIX_NONE, 	\
> +				     _hexdata, _hexdatalen);
\
> +	}
\
> +} while (0)

>From my experiences you need to use:
  if (unlikely(a) && b)
not:
  if (unlikely(a && b))
to get the expected static branch prediction.

Also, only the initial test need be in the #define,
the printfs (etc) can be moved into a real function.
This would reduce the code size (if used more than once).

	David
