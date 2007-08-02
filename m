From: David Miller <davem@davemloft.net>
Subject: Re: ipsec not working in 2.6.23-rc1-git10 when using pfkey
Date: Thu, 02 Aug 2007 15:01:14 -0700 (PDT)
Message-ID: <20070802.150114.66056548.davem@davemloft.net>
References: <200708021858.l72IwbhE018683@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jookos@gmail.com
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40610
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756782AbXHBWBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 18:01:13 -0400
In-Reply-To: <200708021858.l72IwbhE018683@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Thu, 2 Aug 2007 13:58:38 -0500

> Although an ipsec SA was established, kernel couldn't seem to find it.
> 
> I think since we are now using "x->sel.family" instead of "family" 
> in the  xfrm_selector_match() called in xfrm_state_find(), af_key 
> needs to set this field too, just as xfrm_user. 
> 
> In af_key.c, x->sel.family only gets set when there's an 
> ext_hdrs[SADB_EXT_ADDRESS_PROXY-1] which I think is for tunnel.
> 
> I think pfkey needs to also set the x->sel.family field when it is 0.

Thanks for finding this bug Joy.

It basically proves that this inner address change was %100 not tested
in any reasonable way by the patch submitter.

Originally Herbert and I thought I only saw problems because XFRM_USER
cases such as openswan did not set the x->sel.family field, but now
that we see that PF_KEY also has the same exact problem and as a
result I am very annoyed.

Joakim, TEST YOUR PATCHES, and not just with your BEET test cases,
before submitting them in the future.  Having normal configurations of
both PF_KEY and XFRM_USER ipsec totally break as a result of your
changes is totally unacceptable and I will doubly scrutinize your
patch submissions in the future because of what has happened here.

Thanks.
