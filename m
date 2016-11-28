From: Phil Sutter <phil@nwl.cc>
Subject: Re: ip manpage comments
Date: Mon, 28 Nov 2016 11:53:02 +0100
Message-ID: <20161128105302.GU6158@orbyte.nwl.cc>
References: <20161127024932.GA9954@cyber.jgcomp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jon LaBadie <jonfu@jgcomp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35645 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932538AbcK1KxE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 05:53:04 -0500
Content-Disposition: inline
In-Reply-To: <20161127024932.GA9954@cyber.jgcomp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Nov 26, 2016 at 09:49:32PM -0500, Jon LaBadie wrote:
> Though not new to *nix, I am new to using the ip(8) command.
> Thus some of my historical assumptions about ip may be wrong.
> 
> It seems that an inclusive manpage for the ip command was
> broken up into a shorter ip(8) manpage and 15 or more
> ip-<subcommand>(8) manpages.  I'm basing this assumption
> on long, inclusive manpages on https://linux.die.net/man/8/ip
> and CentOS 6 while CentOS 7 and Fedora 24 each have the
> sub-divided style.
> 
> I won't debate the wisdom of this subdivision, only comment
> on how it was done.
> 
> The ip(8) manpage make no mention of additional subordinate
> documents.  The listing of the additional documents in the
> See Also section is insufficient.  This section is typically
> used to mention related commands and other sources of reference
> materials such as info docs, wikis, blogs, or mailing lists.

In what aspect do you think it's insufficient? Only because you don't
think it's the appropriate place to list them or are there any other
reasons? Where do you think would be a better place for them?

Looking at the description of 'SEE ALSO' section in man-pages.7, it is
expected to find "A comma-separated list of related man pages" there.

> When one does investigate one of the subordinate manpages,
> they do not state that they document subcommands of the
> ip command.  In fact, on the ip-address(8) manpage it says
> 
>   The `ip address command' ...   (quotes added)
> 
> My first thought was "typo", this is the manpage about the
> "ip-address" command.  Of course there is no ip-address command.
> But "ip address" is not a command either, it is the "ip" command
> with an argument.

Well, yes and no. While it is true that the command itself on most
systems is 'ip' and 'address' is just the first parameter, by the
internal design 'ip' is merely a dispatcher to the actual subcommand
given. An interesting fact is that main() in ip.c checks argv[0] and in
case it's longer than two characters assumes the remaining part is the
subcommand (i.e. first parameter). So by symlinking 'ip' to 'ipaddress'
I can use the latter as an alternative to calling 'ip address'. You
might argue that the man page then should be named ipaddress.8, but
there is a reason for it not to be like this: Given that most
distributions don't make use of the symlink possibility, the dashed name
allows for opening ip-address.8 using 'man ip address' which is in my
opinion far more intuitive than having to use 'man ipaddress'. (Of
course nothing prevents one from having an ipaddress.8 redirecting to
ip-address.8.)

> There are several commands that have broken their manpage into
> several manpages.  Two which come to mind are zsh(1) and perl(1).
> The authors of those pages clearly state on the primary manpage
> that this is an overview page and give clear pointers to the
> additional manpages as well as additional documentation.  I would
> recommend reorganizing the ip(8) manpage in a similar fashion.

Well, go ahead if you like. Patches are appreciated, and if you put me
in Cc, I'll promise to help by reviewing them.

> Thank you for consideration of my opinion and for the development
> of an awesome tool.

Please keep in mind that you are talking to a community here, not tech
support of a product you bought. :)

Cheers, Phil
