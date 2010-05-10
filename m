From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-next-2.6 2010-05-10
Date: Mon, 10 May 2010 04:28:29 -0700 (PDT)
Message-ID: <20100510.042829.93442711.davem@davemloft.net>
References: <cover.1273484094.git.marcel@holtmann.org>
	<20100510.042031.135962157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53930
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755913Ab0EJL2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 07:28:22 -0400
In-Reply-To: <20100510.042031.135962157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


More problems.

In the future, don't fix things like you did in:

"Bluetooth: Fix issues where sk_sleep() helper is needed now"

That's something you take care of inside of the merge which causes the
build problems.

It's even trivial:

bash$ cd bluetooth-next-2.6
bash$ git pull .../net-next-2.6/.git
bash$ make
... build fails because sk_sleep() stuff ...
bash$ emacs ...
bash$ make
... build succeeds now ...
bash$ git commit --amend file1.c file2.c ...

and add some mention in the amended merge commit about what you did
to take care of the sk_sleep() stuff.  That final commit command
will update the merge commit so that it has the build fix included
in it and therefore at any particular commit the tree does not fail
to build.

Otherwise you create a situation where the tree is not bisectable at
all, if someone bisects to the commit before the sk_sleep() fix the
tree won't build, and this makes bug hunting more painful than it
needs to be.
