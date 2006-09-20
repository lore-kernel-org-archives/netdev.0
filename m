From: Andrey Savochkin <saw@sw.ru>
Subject: Re: [PATCH 4/9] network namespaces: socket hashes
Date: Wed, 20 Sep 2006 20:32:22 +0400
Message-ID: <20060920203222.B10791@castle.nmd.msu.ru>
References: <20060815182029.A1685@castle.nmd.msu.ru> <20060815184844.A2882@castle.nmd.msu.ru> <450EB771.9080609@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:6163 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1751808AbWITQcY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 12:32:24 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <450EB771.9080609@fr.ibm.com>; from "Daniel Lezcano" on Mon, Sep 18, 2006 at 05:12:49PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Sep 18, 2006 at 05:12:49PM +0200, Daniel Lezcano wrote:
> Andrey Savochkin wrote:
> > Socket hash lookups are made within namespace.
> > Hash tables are common for all namespaces, with
> > additional permutation of indexes.
> 
> Hi Andrey,
> 
> why is the hash table common and not instanciated multiple times for 
> each namespace like the routes ?

The main reason is that socket hash tables should be large enough to work
efficiently, but it isn't good to waste a lot of memory for each namespace.
Namespaces should be cheap enough, to allow to have hundreds of them.
This reason of memory efficiency, of course, has a priority unless/until
socket hash tables start to resize automatically.

Another point is that routing lookup is much more complicated than the
socket's one to add another search key.
Routing also have additional routines for deleting entries matching some
patterns, and so on.
In short, routing is much more complicated, and it already quite efficient
for various sizes of routing tables.

	Andrey
