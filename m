From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH v2 03/13] QLogic VNIC: Implementation of
	communication protocol with EVIC/VEx
Date: Tue, 27 May 2008 22:28:46 -0700
Message-ID: <adaod6rq9o1.fsf@cisco.com>
References: <20080519102843.12355.832.stgit@localhost.localdomain>
	<20080519103258.12355.6146.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org, amar.mudrankit@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080519103258.12355.6146.stgit@localhost.localdomain>
	(Ramachandra K.'s message of "Mon, 19 May 2008 16:02:58 +0530")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > +void viport_disconnect(struct viport *viport)
 > +{
 > +	VIPORT_FUNCTION("viport_disconnect()\n");
 > +	viport->disconnect = 1;
 > +	viport_failure(viport);
 > +	wait_event(viport->disconnect_queue, viport->disconnect == 0);
 > +}
 > +
 > +void viport_free(struct viport *viport)
 > +{
 > +	VIPORT_FUNCTION("viport_free()\n");
 > +	viport_disconnect(viport);	/* NOTE: this can sleep */

There are no other calls to viport_disconnect() that I can see, so it
can be made static (and the declaration in vnic_viport.h can be dropped).
in fact given how small the function is and the fact that it has only a
single call site, it might be easier just to merge it into
viport_free().  But that's a matter of taste.

 - R.
