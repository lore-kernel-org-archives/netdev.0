From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next patch] bnx2x: Define bnx2x_tests_str_arr as const
Date: Wed, 27 Jun 2012 12:59:22 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F68@saturn3.aculab.com>
References: <1340797976-13827-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Merav Sicron" <meravs@broadcom.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43993 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753605Ab2F0MAm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 08:00:42 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14105-06 for <netdev@vger.kernel.org>;
 Wed, 27 Jun 2012 13:00:37 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1340797976-13827-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> -static char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
> +static const char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
>  	"register_test (offline)    ",
>  	"memory_test (offline)      ",
>  	"int_loopback_test (offline)",

You are still missing a 'const'.
You probably want:
  static const char *const bnx2x_tests_str_arr[] ...

However if you are going to pad the strings to [28]
you might as well remove the layer of indirection - ie:
  static const char bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF][28] = { ...
}
Or pad to 32 chars to (probably) remove some code bytes.

	David
