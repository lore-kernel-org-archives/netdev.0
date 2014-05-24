From: Jon Maxwell <jmaxwell@redhat.com>
Subject: Re: [PATCH net] bridge: notify user space of fdb port change
Date: Fri, 23 May 2014 21:33:48 -0400 (EDT)
Message-ID: <1655748249.12329071.1400895228522.JavaMail.zimbra@redhat.com>
References: <1399967708-7283-1-git-send-email-jmaxwell@redhat.com> <5372BA1E.8000402@lab.ntt.co.jp> <2052318198.6465872.1400101664337.JavaMail.zimbra@redhat.com> <1679971005.11740655.1400821172875.JavaMail.zimbra@redhat.com> <537F0951.5010904@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jon Maxwell <jmaxwell37@gmail.com>, stephen@networkplumber.org,
	davem@davemloft.net, vyasevic@redhat.com,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jpirko@redhat.com
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx5-phx2.redhat.com ([209.132.183.37]:45432 "EHLO
	mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbaEXBdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 21:33:54 -0400
In-Reply-To: <537F0951.5010904@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I have no more comments except for style problems (bracket position,
> indentation, type mismatch).
> thank you for rewriting :)

np, yes this is a draft but I will make sure complies with checkpatch.pl
before submitting it.

Regards

Jon

> 
> Thanks,
> Toshiaki Makita
> 
> > 
> > $ diff -Naur br_fdb.c br_fdb.c.patch
> > --- br_fdb.c        2014-05-17 12:43:23.346319609 +1000
> > +++ br_fdb.c.patch        2014-05-17 16:54:46.280235728 +1000
> > @@ -487,6 +487,7 @@
> >  {
> >          struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
> >          struct net_bridge_fdb_entry *fdb;
> > +        bool fdb_modified = 0;
> >  
> >          /* some users want to always flood. */
> >          if (hold_time(br) == 0)
> > @@ -507,10 +508,16 @@
> >                                          source->dev->name);
> >                  } else {
> >                          /* fastpath: update of existing entry */
> > -                        fdb->dst = source;
> > +                        if (unlikely(source != fdb->dst))
> > +                                {
> > +                                fdb->dst = source;
> > +                                fdb_modified = 1;
> > +                                }
> >                          fdb->updated = jiffies;
> >                          if (unlikely(added_by_user))
> >                                  fdb->added_by_user = 1;
> > +                        if (unlikely(fdb_modified))
> > +                                fdb_notify(br, fdb, RTM_NEWNEIGH);
> >                  }
> >          } else {
> >                  spin_lock(&br->hash_lock);
> > 
> > 
> 
