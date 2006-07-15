From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sat, 15 Jul 2006 11:14:30 -0400
Message-ID: <200607151114.30648.paul.moore@hp.com>
References: <20060714185739.780700000@flek.zko.hp.com> <20060714185915.270209000@flek.zko.hp.com> <Pine.LNX.4.64.0607150913510.24495@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:41898 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1750701AbWGOPOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2006 11:14:44 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0607150913510.24495@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 15 July 2006 9:15 am, James Morris wrote:
> On Fri, 14 Jul 2006, paul.moore@hp.com wrote:
> > +int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
> > +{
> > +	if (doi_def == NULL || doi_def->doi == CIPSO_V4_DOI_UNKNOWN)
> > +		return -EINVAL;
> > +
> > +	doi_def->valid = 1;
> > +	INIT_RCU_HEAD(&doi_def->rcu);
> > +	INIT_LIST_HEAD(&doi_def->dom_list);
> > +
> > +	rcu_read_lock();
> > +	if (cipso_v4_doi_search(doi_def->doi) != NULL) {
> > +		rcu_read_unlock();
> > +		return -EEXIST;
> > +	}
> > +	spin_lock(&cipso_v4_doi_list_lock);
> > +	list_add_tail_rcu(&doi_def->list, &cipso_v4_doi_list);
> > +	spin_unlock(&cipso_v4_doi_list_lock);
> > +	rcu_read_unlock();
> > +
> > +	return 0;
> > +}
>
> This is racy in that you can end up with duplicate entries in the list
> between rcu_read_lock() and spin_lock().
>
> You need to perform the search a second time under the spin_lock() as a
> slow path to verify that an entry wasn't added, before adding a new one.
>

Thanks, there are a few more place which might have similar problems - I'll 
check those as well.

-- 
paul moore
linux security @ hp
