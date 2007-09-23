From: jamal <hadi@cyberus.ca>
Subject: Re: pktgen question
Date: Sun, 23 Sep 2007 14:18:47 -0400
Message-ID: <1190571527.4256.78.camel@localhost>
References: <46F6905C.6030309@opengridcomputing.com>
	 <20070923172803.GA11997@2ka.mipt.ru>
	 <46F6A887.1030301@opengridcomputing.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:2989 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755024AbXIWSSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 14:18:51 -0400
Received: by an-out-0708.google.com with SMTP id d31so196561and
        for <netdev@vger.kernel.org>; Sun, 23 Sep 2007 11:18:51 -0700 (PDT)
In-Reply-To: <46F6A887.1030301@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-23-09 at 12:55 -0500, Steve Wise wrote:

> Its a hack that breaks cxgb3 because cxgb3 uses the skb->cb area for 
> each skb passed down.  So cxgb3 is at fault then?  IE a driver cannot 
> use the skb->cb field if the users count is > 1?  Or maybe a driver can 
> _never_ use the cb field?

any layer can use the cb structure whichever way they wish. There are
violations, e.g:
the vlan code also uses the cb field to pass vlan details for hardware
acceleration. How does pktgen affect it though, clone() will just copy
the cb field and pktgen doesnt touch it.
In retrospect, pktgen may have to use clone - ccing Robert Olsson.

cheers,
jamal

