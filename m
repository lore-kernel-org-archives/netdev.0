From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Tue, 5 Dec 2006 22:20:47 +0100
Message-ID: <200612052220.47816.IvDoorn@gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com> <200612032328.12093.IvDoorn@gmail.com> <20061204161842.a8673e6e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	Dmitry Torokhov <dtor@insightbb.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Lennart Poettering <lennart@poettering.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:63026 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031544AbWLEVUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 16:20:54 -0500
Received: by nf-out-0910.google.com with SMTP id o25so338857nfa
        for <netdev@vger.kernel.org>; Tue, 05 Dec 2006 13:20:52 -0800 (PST)
To: Randy Dunlap <randy.dunlap@oracle.com>
In-Reply-To: <20061204161842.a8673e6e.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[snip]
 
> > +/*
> > + * Function called by the key driver to report the new status
> > + * of the key.
> > + */
> > +void rfkill_report_event(struct rfkill *rfkill, int new_status)
> > +{
> > +	mutex_lock(&master->mutex);
> > +
> > +	if (rfkill_check_key(rfkill->key, new_status))
> > +		schedule_work(&master->toggle_work);
> > +
> > +	mutex_unlock(&master->mutex);
> > +}
> > +EXPORT_SYMBOL_GPL(rfkill_report_event);
> 
> Please use kernel-doc notation for non-static functions.
> See Documentation/kernel-doc-nano-HOWTO.txt for more info.

All kernel-doc notations were placed in the rfkill.h header.
I'll move them to the rfkill.c file.


[snip]

> > + * @rfkill: rfkill structure to be deregistered
> > + * @init_status: initial status of the key at the time this function is called
> > + *
> > + * This function should be called by the key driver when the rfkill structure
> > + * needs to be registered. Immediately from registration the key driver
> > + * should be able to receive calls through the poll, enable_radio and
> > + * disable_radio handlers if those were registered.
> > + */
> > +int rfkill_register_key(struct rfkill *rfkill, int init_status);
> > +
> > +/**
> > + * rfkill_deregister_key - Deregister a previously registered rfkill structre.
> 
> "structure"

Thanks for the pointers. I'll fix them asap.

Ivo
