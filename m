From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 2/2] bridge: netlink dump interface at par with
 brctl
Date: Sun, 15 Jun 2014 11:28:53 -0400
Message-ID: <539DBBB5.3000906@mojatatu.com>
References: <1402151244-3324-1-git-send-email-jhs@emojatatu.com> <1402151244-3324-2-git-send-email-jhs@emojatatu.com> <5395E3C4.5080904@redhat.com> <5396EF01.7030009@mojatatu.com> <53970745.7040002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com
To: vyasevic@redhat.com, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:44397 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaFOP3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 11:29:07 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so2073162igd.14
        for <netdev@vger.kernel.org>; Sun, 15 Jun 2014 08:29:05 -0700 (PDT)
In-Reply-To: <53970745.7040002@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/14 09:25, Vlad Yasevich wrote:

>
> I gave it some thought and I think something like the following
> pseudo-code would work.
>
> dump_dev_fdbs(dev, filter)
> {
>          if (dev->dumper)
>                  dev->ndo_dumper(dev, filter);
>          else
>                  default_dumper(dev, filter);
> }
>
> for_each_netdev() {
>          if (bridge_filter) {
>                  if (dev->index != bridge_filter)
>                          skip;
>
>                  dump_dev_fdbs(dev, port_filter);
>          } else {
>                  if (port_filter) {
>                          if (bridge_port &&
>                              dev->index != port_filter)
>                                  skip;
>
>                  }
>
>                  if (bridge_port) {
>                          br_dev = get_bridge();
>                          dump_dev_fdbs(br_dev, port_filter);
>                  }
>
>                  dump_dev_fdbs(dev, port_filter);
>          }
> }
>
>
> What do you think?

Too bad i missed the net-next submission.
I am not sure what you suggest above will improve upon readability,
but i will take another run at it when Dave opens up.
I know reading the patch was hard - the code was not as bad.
We'll see.

cheers,
jamal
