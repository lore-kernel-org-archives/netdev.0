From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/3] netdevice: remove useless else keyword
Date: Tue, 06 Aug 2013 07:37:40 -0700
Message-ID: <1375799860.2424.26.camel@joe-AO722>
References: <1375774371-831-1-git-send-email-sakiwit@gmail.com>
	 <1375774371-831-2-git-send-email-sakiwit@gmail.com>
	 <5200B1DF.2000701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52066 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752653Ab3HFOhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 10:37:40 -0400
In-Reply-To: <5200B1DF.2000701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 10:20 +0200, Daniel Borkmann wrote:
> On 08/06/2013 09:32 AM, Jean Sacren wrote:
> > Clean up multiple useless else keywords. Add empty lines for
> > readability.
> 
> Hmm, don't really think this is actually needed or makes things better.

Maybe that's true.

Though this patch is pretty trivial and
I would (probably) not submit it, I think
it's a reasonable style rule to not use
else after an if() that always returns.

	if (foo)
		return bar;

	next_statement;

should be preferred over

	if (foo)
		return bar;
	else
		next_statement;

The blank lines though are a style taste.
Maybe removing the blank line before the
first if in this patch might be better.

{
	BUG_ON(!net);

	if (!dev_valid_name(name))
		return -EINVAL;
	if (strchr(name, '%'))
		return dev_alloc_name_ns(net, dev, name);
	if (__dev_get_by_name(net, name))
		return -EEXIST;
	if (dev->name != name)
		strlcpy(dev->name, name, IFNAMSIZ);

	return 0;
}
