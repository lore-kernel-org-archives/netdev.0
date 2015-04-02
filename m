From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH iproute2 -next] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Thu, 2 Apr 2015 13:10:03 +0100
Message-ID: <20150402121003.GA21588@casper.infradead.org>
References: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net>
 <1427933636.1888890.248325033.0A76BE0D@webmail.messagingengine.com>
 <551C8C2D.5060504@iogearbox.net>
 <1427934556.1892386.248333013.431CD73B@webmail.messagingengine.com>
 <551D17B4.2090903@iogearbox.net>
 <1427974255.2093319.248499373.05D36231@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org,
	ast@plumgrid.com, jiri@resnulli.us, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35644 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbbDBMKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 08:10:06 -0400
Content-Disposition: inline
In-Reply-To: <1427974255.2093319.248499373.05D36231@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/15 at 01:30pm, Hannes Frederic Sowa wrote:
> On Thu, Apr 2, 2015, at 12:19, Daniel Borkmann wrote:
> > I'm probably missing something, would that need changes to bash?
> > 
> > I mean exec could bind an fd in the shell to sockets and use that,
> > for example ...
> > 
> >    exec 3<>/dev/tcp/www.slashdot.org/80
> >    echo -e "GET / HTTP/1.1\r\nhost:
> >    http://www.slashdot.org\r\nConnection: close\r\n\r\n" >&3
> >    cat <&3
> > 
> > ... perhaps such a built-in fake device for retrieving bpf map fds
> > might be interesting, e.g. exec 4<>/dev/bpf/<obj-file>/<map-name> if
> > that has been given to bash?
> > 
> > Anyway, I think to have some utility for shell scripts, as you
> > suggest, certainly sounds interesting!
> 
> All file descriptors will be inherited by exec as long as the O_CLOEXEC
> flag wasn't specified on them. So you can retrieve the fds via af_unix
> and just exec a new shell. The file descriptors will stay open and you
> can pass the numbers of the fds via environment. This wouldn't need
> changes to bash or kernel.

We also have to consider implementing a way to reopen the fds after
the original process has crashed but I agree this is a great start
for the tc environment.
