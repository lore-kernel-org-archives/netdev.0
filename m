From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] openvswitch: Use regular GRE net_device
 instead of vport
Date: Mon, 3 Aug 2015 23:01:41 -0700
Message-ID: <20150804060140.GA47336@Alexeis-MBP.westell.com>
References: <1438648046-10346-1-git-send-email-pshelar@nicira.com>
 <20150804042339.GA47032@Alexeis-MBP.westell.com>
 <CALnjE+q-sBLWE5WPY451YYG8zv9g2E00aKkRHGo1cDf+xGAGnA@mail.gmail.com>
 <20150804055359.GA47320@Alexeis-MBP.westell.com>
 <CALnjE+ruRdOhs1=E1ZRyPdhoKFr08yqZJvh3Z21wE-yjRgg4hQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36196 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702AbbHDGBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 02:01:45 -0400
Received: by pacgq8 with SMTP id gq8so42534302pac.3
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 23:01:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALnjE+ruRdOhs1=E1ZRyPdhoKFr08yqZJvh3Z21wE-yjRgg4hQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 03, 2015 at 10:58:02PM -0700, Pravin Shelar wrote:
> >> > feature detection based on netdev name?
> >> > meaning that there will be only one such device for the whole
> >> > host? and namespaces cannot have their own gre tunnels?
> >> > (since host 'gretap0' cannot be seen in netns)
> >> >
> >> gretap0 exist in every namespace. This device is created in GRE namespce init.
> >
> > then all of them get to be in flow_based mode without being able to
> > change it?
> >
> Yes, But there is no side effect of this feature for the user of the device.

other than allocating metadata_dst for every incoming packet?
If you could actually do it for free then we wouldn't need a flag.
