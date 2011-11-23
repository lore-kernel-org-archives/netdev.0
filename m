From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/2] ax25: integer overflows in ax25_setsockopt()
Date: Wed, 23 Nov 2011 10:44:49 +0000
Message-ID: <20111123104449.5e845a0f@lxorguk.ukuu.org.uk>
References: <7187C142-99F1-4A96-9BE6-650B10C9B22D@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <7187C142-99F1-4A96-9BE6-650B10C9B22D@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  	case AX25_T1:
> -		if (opt < 1) {
> +		if (opt < 1 || opt > 30) {

Where do these values come from ? If they are from some 'standard' then
really we should avoid restricting needlessly to it, particularly as
AX.25 isn't well defined and is used for all sorts of crazy stuff where
the usual range of settings isn't useful.

Restricting to the point it would overflow makes sense however.

Alan

