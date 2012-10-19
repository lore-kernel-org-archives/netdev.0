From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next 08/14] igb: Combine post-processing of skb into a single function
Date: Fri, 19 Oct 2012 14:49:40 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7058@saturn3.aculab.com>
References: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com> <1350647114-6768-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Alexander Duyck" <alexander.h.duyck@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40510 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753869Ab2JSN4v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 09:56:51 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03662-04 for <netdev@vger.kernel.org>;
 Fri, 19 Oct 2012 14:56:46 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1350647114-6768-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change is meant to just clean-up a number of function calls that were
> made at the end of the Rx clean-up path by combining them into a single
> function call.

Since the functions are static and only called once they
are prime candidates for inlining.
This might happen anyway (depending on the gcc version
and the direction the wind is blowing in).

Marking them with __attribute__((always_inline)) might
be needed to get them actually inlined.

That would maintain the logical separation.

	David
