From: Ivo Clarysse <ivo.clarysse@gmail.com>
Subject: Re: [PATCH 1/2] Add an alternative cs89x0 driver
Date: Wed, 22 Apr 2009 11:28:17 +0200
Message-ID: <ba216b430904220228o369d0a5eg79c876733dcc7c8c@mail.gmail.com>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de>
	 <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Lennert Buytenhek <kernel@wantstofly.org>,
	Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:34725 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581AbZDVJed convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 05:34:33 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1923021ywb.1
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 02:34:31 -0700 (PDT)
In-Reply-To: <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 9:59 AM, Sascha Hauer <s.hauer@pengutronix.de> =
wrote:

> +#define CS8900A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x000=
0
> +#define REV_B =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A07
> +#define REV_C =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A08
> +#define REV_D =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A09

These REV_B / REV_C / REV_D defines are not used, and in fact depend
on the cs89x0x variant.

> + =A0 =A0 =A0 dev_info(&pdev->dev, "CS8900A rev %c detected\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 'B' + REVISION(value) -=
 REV_B);

This will report incorrectly for CS8900 (not CS8900A),  and for CS8900A=
 rev. F:

According to the CS8900A and CS8920A datasheets, the product ID should
be interpreted as:

0x0700  CS8900A rev. B
0x0800  CS8900A rev. C
0x0900  CS8900A rev. D
0x0A00  CS8900A rev. F
0x6100  CS8920 rev. B
0x6200  CS8920 rev. C
0x6300  CS8920 rev. D
0x6400  CS8920A rev. A/B
0x6500  CS8920A rev. C

(I couldn't find the datasheet for the original CS8900; acoording to
http://www.cirrus.com/en/products/eol/index.html, the CS8900A is the
only CS89X0X variant which is not EOL)


Ivo.
