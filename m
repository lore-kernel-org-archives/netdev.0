From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] lib/bpf: Fix bytecode-file parsing
Date: Wed, 30 Aug 2017 16:11:56 +0200
Message-ID: <20170830141155.GH20614@orbyte.nwl.cc>
References: <20170829150945.7077-1-phil@nwl.cc>
 <59A6C377.90705@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59185 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751735AbdH3OL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 10:11:57 -0400
Content-Disposition: inline
In-Reply-To: <59A6C377.90705@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On Wed, Aug 30, 2017 at 03:53:59PM +0200, Daniel Borkmann wrote:
> On 08/29/2017 05:09 PM, Phil Sutter wrote:
[...]
> > @@ -228,18 +229,20 @@ static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
> >   			case '\n':
> >   				if (c_prev != ',')
> >   					*(pos++) = ',';
> > +				c_prev = ',';
> >   				break;
> >   			case ' ':
> >   			case '\t':
> >   				if (c_prev != ' ')
> >   					*(pos++) = c;
> > +				c_prev = ' ';
> >   				break;
> >   			default:
> >   				*(pos++) = c;
> > +				c_prev = c;
> >   			}
> >   			if (pos - tmp_string == tmp_len)
> >   				break;
> > -			c_prev = c;
> 
> I don't really have a strong opinion on this, but the logic for
> normalizing here is getting a bit convoluted. Is your use case
> for making the parser more robust mainly so you can just use the
> -ddd output from tcpdump for cBPF w/o piping through tr? But even
> that shouldn't give multiple empty lines afaik, no?

Well, using tcpdump output was functional before already. I just noticed
that if I add an empty line to the end of bytecode-file, it will fail
and I didn't like that. Then while searching for the EOF issue, I
noticed that the parser logic above is a bit faulty in that it will
treat different characters equally but doesn't make sure c_prev will be
assigned only one of them. So apart from the added robustness, it really
fixes an inconsistency in the parsing logic.

Cheers, Phil
