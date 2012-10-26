From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] sctp: Clean up type-punning in sctp_cmd_t union
Date: Fri, 26 Oct 2012 10:00:13 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B706F@saturn3.aculab.com>
References: <1351198075-20385-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Vlad Yasevich" <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-sctp@vger.kernel.org>
To: "Neil Horman" <nhorman@tuxdriver.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36195 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752981Ab2JZJBL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 05:01:11 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20025-01 for <netdev@vger.kernel.org>;
 Fri, 26 Oct 2012 10:01:06 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1351198075-20385-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH] sctp: Clean up type-punning in sctp_cmd_t union
...
> +#define SCTP_NULL_BYTE 0xAA
>  static inline sctp_arg_t SCTP_NULL(void)
>  {
> -	sctp_arg_t retval; retval.ptr = NULL; return retval;
> +	sctp_arg_t retval;
> +	memset(&retval, SCTP_NULL_BYTE, sizeof(sctp_arg_t));
> +	return retval;
>  }

You really don't want to be taking the address of a local
variable that would normally be held in a register.
It stops the compiler doing a lot of optimisations.
In this case the structure is also being returned by value,
not nice except that all(?) modern ABI do pass small structures
in registers.

An assignment of some member of the union to NULL would
seem most appropriate.
OTOH the code that uses this must be someones 'bright idea (tm)'
that probably wasn't such a good idea after all.

	David
