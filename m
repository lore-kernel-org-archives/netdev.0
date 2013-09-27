From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] iproute2: xfrm state add abort issue
Date: Fri, 27 Sep 2013 09:26:15 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7361@saturn3.aculab.com>
References: <524411AE.7000404@linux.vnet.ibm.com> <52447DAC.2060701@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "Sohny Thomas" <sthomas@linux.vnet.ibm.com>,
	<stephen@networkplumber.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59769 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751878Ab3I0I2s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 04:28:48 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23042-09 for <netdev@vger.kernel.org>;
 Fri, 27 Sep 2013 09:28:47 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <52447DAC.2060701@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ip xfrm state add causes a SIGABRT due to a strncpy_chk .
> This happens since strncpy doesn't account for the '\0' .
> I have fixed this using sizeof  instead of strlen .
> 
> There is a redhat bug which documents this issue
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=982761
> 
> Signed-off-by: Sohny Thomas <sohthoma@in.ibm.com>
> 
> --------------
> 
> diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
> index 389942c..7dd8799 100644
> --- a/ip/xfrm_state.c
> +++ b/ip/xfrm_state.c
> @@ -117,7 +117,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg,
> enum xfrm_attr_type_t type,
>                              char *name, char *key, char *buf, int max)
>    {
>           int len;
> -       int slen = strlen(key);
> +       int slen = sizeof(key);

you definitely don't want sizeof(key) - that is either 4 or 8.

	David
