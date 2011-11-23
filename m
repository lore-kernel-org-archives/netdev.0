From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [patch] netrom: check that user string is terminated
Date: Wed, 23 Nov 2011 19:12:49 +0000
Message-ID: <20111123191249.GB7260@linux-mips.org>
References: <20111123065240.GD6871@elgon.mountain>
 <4ECCAD38.9090309@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4ECCAD38.9090309@bfs.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2011 at 09:22:16AM +0100, walter harms wrote:

> I am not sure that it does what you intends.
> mnemonic is an array and a  malicious use may fill it upto the last char
> causing strlen go beyond. perhaps this may help:

Correct, it makes thigs worse.  I'm going to reply in detail later tonight,
have to bail out now.

> >  		if ((dev = nr_ax25_dev_get(nr_route.device)) == NULL)
> >  			return -EINVAL;
> while you are here:
> 
> 	dev = nr_ax25_dev_get(nr_route.device);
> 	if ( dev == NULL )
> 		return -EINVAL;
> 
> >  		if (nr_route.ndigis < 0 || nr_route.ndigis > AX25_MAX_DIGIS) {
> 
> if guess "nr_route.ndigis >= AX25_MAX_DIGIS" is intended ?

No, values of 0 .. AX25_MAX_DIGIS are permitted with zero meaning no
digipeater at all.

The actual bug if you want to call it that in this line is cosmetic -
nr_route.ndigis is an unsigned int so nr_route.ndigis < 0 will never become
true.  There are other simplifications possible to the error checking
here.  I've whipped a cleanup patch for this part of the code.

  Ralf
