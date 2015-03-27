From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [RFC net-next 1/2] net: allow user to set IPv6 nexthop for IPv4
 route
Date: Fri, 27 Mar 2015 10:35:23 -0400
Message-ID: <20150327143522.GH1051@gospo>
References: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com>
 <1427403928-1342-2-git-send-email-gospo@cumulusnetworks.com>
 <CACP96tQjVxSgh3m7ext5P+iyY2tPXy3O6R+UQ4wv44MRjFQvZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Bjornar Ness <bjornar.ness@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:33885 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941AbbC0Off (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 10:35:35 -0400
Received: by yhch68 with SMTP id h68so39331225yhc.1
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 07:35:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CACP96tQjVxSgh3m7ext5P+iyY2tPXy3O6R+UQ4wv44MRjFQvZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 09:23:57AM -0400, Sowmini Varadhan wrote:
> On Thu, Mar 26, 2015 at 5:05 PM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > This adds kernel infrastructure to allow userspace (read: routing protocols) to
> > support adding IPv6 next-hops to IPv4 routes.  This is essentially added to
> > support a feature of MP-BGP outlined in RFC-5549.
> >
> > Thise does not encompass all that is needed to support RFC-5549, but this
> > demonstrates the netlink infrastructure needed to correctly enable the kernel
> > infrastructure that would support this RFC.  For more informtion the full RFC
> > is here: http://www.ietf.org/rfc/rfc5549.txt.
> 
> Is there some impact to redirect behavior? RFC 5549 does not seem to
> discuss it at all, but the firsthop would be processing (and
> potentially sending)
> an icmp redirect to the host. I dont think there is a good way to construct
> this, either with icmpv4 or icmpv6, and maybe some checks are needed to
> not even try, when the IP mix-match is encountered.
> 

You are correct that there is not a great way to construct this since
the frames at strictly IPv4 frames.  I'll have to dig into this a bit
more to see if there is something worth doing for this case.
