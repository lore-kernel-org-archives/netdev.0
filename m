From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 14/16] net: dsa: Add new binding implementation
Date: Fri, 27 May 2016 22:57:59 +0200
Message-ID: <20160527205759.GB6027@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
 <1464312050-23023-15-git-send-email-andrew@lunn.ch>
 <8737p3z15i.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53151 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575AbcE0U6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2016 16:58:01 -0400
Content-Disposition: inline
In-Reply-To: <8737p3z15i.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2016 at 04:39:05PM -0400, Vivien Didelot wrote:
> 
> Hi Andrew, Florian,
> 
> Here again, I'd suggested an implicit namespace for functions taking a
> dsa_switch_tree structure as first argument, i.e. dsa_tree_do_foo().

Using tree actually makes things worse, since tree is never used
anywhere in the current code. It is always called dst. If you do this,
you also need to replace every instance of dst with tree.

We mostly have a good convention

struct dsa_switch *ds;
dsa_switch_tree *dst;

What is not quite consistent is

struct dsa_chip_data *cd

which should really be

struct dsa_chip_data *dcd

but we are consistent with using cd everywhere.
 
> Since we are likely to spend some time in net/dsa, it'd be great to
> introduce the new bindings and an intuitive API at the same time ;-)

They are two separate things. And the binding will be set in stone,
never to be changed again in incompatible ways, where as the API we
can change as much as we like. We should be concentrate on the
binding.

    Andrew
