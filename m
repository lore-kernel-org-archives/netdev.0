From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Tue, 5 Dec 2006 22:21:06 +0100
Message-ID: <200612052221.07229.IvDoorn@gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com> <20061205103239.GA10312@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Lennart Poettering <lennart@poettering.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:63127 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031553AbWLEVVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 16:21:10 -0500
Received: by nf-out-0910.google.com with SMTP id o25so338856nfa
        for <netdev@vger.kernel.org>; Tue, 05 Dec 2006 13:21:09 -0800 (PST)
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061205103239.GA10312@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 05 December 2006 11:32, Christoph Hellwig wrote:
> > +/*
> > + * Function called by the key driver when the rfkill structure
> > + * needs to be registered.
> > + */
> > +int rfkill_register_key(struct rfkill *rfkill, int init_status)
> > +{
> > +	struct rfkill_type *type = &master->type[rfkill->key_type];
> > +	struct rfkill_key *key;
> > +	int status;
> > +
> > +	if (!rfkill)
> > +		return -EINVAL;	
> > +
> > +	if (rfkill->key_type >= KEY_TYPE_MAX)
> > +		return -EINVAL;
> > +
> > +	/*
> > +	 * Increase module use count to prevent this
> > +	 * module to be unloaded while there are still
> > +	 * registered keys.
> > +	 */
> > +	if (!try_module_get(THIS_MODULE))
> > +		return -EBUSY;
> 
> This is obviously broken.  Please add a "struct module *owner;"
> field to struct rfkill instead.

Thanks, will fix this asap.

Ivo
