From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] netconsole: fix NULL pointer dereference
Date: Thu, 24 Oct 2013 11:39:02 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73A9@saturn3.aculab.com>
References: <1382533489-19248-1-git-send-email-nikolay@redhat.com> <20131024102147.GD16787@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: "Veaceslav Falico" <vfalico@redhat.com>,
	"Nikolay Aleksandrov" <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54968 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754450Ab3JXKlP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 06:41:15 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24662-02 for <netdev@vger.kernel.org>;
 Thu, 24 Oct 2013 11:41:12 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20131024102147.GD16787@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Taking the spinlock seems like the cleanest way to insure there's noone
> >running in parallel, but I'm open to suggestions as I'm not satisfied with
> >the looks of this. I'll prepare a net-next patchset for netconsole soon to
> >clean it up properly, all of these can be easily simplified.
> 
> First when I've seen 'spin_lock(); a = 1; spin_unlock()' I've thought
> "WTF?", however indeed it will stop us racing with write_msg().

Ditto - might be worth saying:
    /* Acquire lock to wait for any write_msg() to complete. */

	David
