From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/3] bna: change type of bna_id to atomic_t
Date: Mon, 1 Aug 2016 14:20:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F50672B@AcuExch.aculab.com>
References: <1469814778-23186-1-git-send-email-ivecera@redhat.com>
 <1469814778-23186-3-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "rasesh.mody@qlogic.com" <rasesh.mody@qlogic.com>
To: 'Ivan Vecera' <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:63587 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbcHAOYd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 10:24:33 -0400
In-Reply-To: <1469814778-23186-3-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera
> Sent: 29 July 2016 18:53
> Change type of bna_id to atomic_t. The bnad_list_mutex is used to prevent
> a race when bna_id is incremented. After the change the mutex can be
> removed in the next step.
...
> -static u32 bna_id;
> +static atomic_t bna_id;
...
>  	bnad_lock_init(bnad);
>  	bnad_add_to_list(bnad);
> +	bnad->id = atomic_inc_return(&bna_id) - 1;
...

Is the 'id' expected to be unique?
Looks like they get reallocated after 2^32 allocates.

	David
