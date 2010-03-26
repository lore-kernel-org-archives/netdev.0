From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP
 multi-link
Date: Fri, 26 Mar 2010 16:02:26 +0000
Message-ID: <20100326160226.0159ac3b@lxorguk.ukuu.org.uk>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
To: Richard Hartmann <richih.mailinglist@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We are fully aware that this code is not nearly up for inclusion into
> the kernel. What we hope to achieve is that someone with the skills to
> do this properly will introduce an option to turn off fragmentation on
> PPP multi-link or to just do away with it completely.

You should be able to manage that I'm sure:

The main thing will be to take this chunk, strip out the // stuff and
then make it a function of its own so you've got clean code in the main
path of the form

#ifdef CONFIG_PPP_MULTILINK
	if (ml_explode) {
		if (!ppp_mp_explode(...)
	..
	} else {
		ppp_mp_roundrobin(...)
	}

and your bits as a new routine. You can then do this

static int ml_explode = 1;
module_param(ml_explode, int, 0600);
MODULE_PARM_DESC(ml_expode, "Set this to zero to disabling multilink \
	fragmentation when talking to cisco devices");

which will let you load the module with the option ml_explode = 0 if you
want that property.

Making it runtime per link selectable would be nicer but thats a bit more
work.

Alan

