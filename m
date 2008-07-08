From: Jim Rees <rees@umich.edu>
Subject: Re: setsockopt()
Date: Tue, 8 Jul 2008 16:12:18 -0400
Message-ID: <20080708201217.GA16119@citi.umich.edu>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu> <20080707.144912.76654646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aglo@citi.umich.edu, shemminger@vyatta.com, bfields@fieldses.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:6306 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754540AbYGHUMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 16:12:18 -0400
Content-Disposition: inline
In-Reply-To: <20080707.144912.76654646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

  If you set the socket buffer sizes explicitly, you essentially turn
  off half of the TCP stack because it won't do dynamic socket buffer
  sizing afterwards.
  
  There is no reason these days to ever explicitly set the socket
  buffer sizes on TCP sockets under Linux.

So it seems clear that nfsd should stop setting the socket buffer sizes.

The problem we run into if we try that is that the server won't read any
incoming data from its socket until an entire rpc has been assembled and is
waiting to be read off the socket.  An rpc can be almost any size up to
about 1MB, but the socket buffer never grows past about 50KB, so the rpc can
never be assembled entirely in the socket buf.

Maybe the nfsd needs a way to tell the socket/tcp layers that it wants a
minimum size socket buffer.  Or maybe nfsd needs to be modified so that it
will read partial rpcs.  I would appreciate suggestions as to which is the
better fix.
