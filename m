From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [PATCH 2.6.28 3/4] myri10ge: Add Toeplitz-hashing related
 routines
Date: Fri, 12 Sep 2008 15:32:26 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F156E465D@orsmsx501.amr.corp.intel.com>
References: <48CAAAEF.1060205@myri.com> <48CAAB93.2070703@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brice Goglin <brice@myri.com>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36075 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753883AbYILWcb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 18:32:31 -0400
In-Reply-To: <48CAAB93.2070703@myri.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> myri10ge uses a Toeplitz hashing. Add the corresponding select_queue()
> method without using it yet.
>
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
...
> +       /*
> +        * Note hashing order is reversed from how it is done
> +        * in the NIC, so as to generate the same hash value
> +        * for the connection to try to keep connections CPU local
> +        */
Have you given this any consideration in terms of routing performance?  It
seems to me that if you didn't reorder things you should be able to generate
the same exact hash value that you would have received on the receive side.
The end result being that packets received on queue 1 would transmit on queue
1, thus saving you a lot of cross queue thrash when routing.  Of course this
all relies on the rss_key being global and shared between ports.

Alex
