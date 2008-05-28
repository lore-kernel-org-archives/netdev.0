From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v2 03/13] QLogic VNIC: Implementation of
	communication protocol with EVIC/VEx
Date: Wed, 28 May 2008 19:48:28 +0530
Message-ID: <71d336490805280718j79c3ea24j4408b851eb0a23ab@mail.gmail.com>
References: <20080519102843.12355.832.stgit@localhost.localdomain>
	<20080519103258.12355.6146.stgit@localhost.localdomain>
	<adaod6rq9o1.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amar.mudrankit@qlogic.com,
	general@lists.openfabrics.org, poornima.kamath@qlogic.com
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adaod6rq9o1.fsf@cisco.com>
Content-Disposition: inline
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

Roland,

Thanks. Will fix both the items you pointed out.

Regards,
Ram

On Wed, May 28, 2008 at 10:58 AM, Roland Dreier <rdreier@cisco.com> wrote:
>  > +void viport_disconnect(struct viport *viport)
>  > +{
>  > +    VIPORT_FUNCTION("viport_disconnect()\n");
>  > +    viport->disconnect = 1;
>  > +    viport_failure(viport);
>  > +    wait_event(viport->disconnect_queue, viport->disconnect == 0);
>  > +}
>  > +
>  > +void viport_free(struct viport *viport)
>  > +{
>  > +    VIPORT_FUNCTION("viport_free()\n");
>  > +    viport_disconnect(viport);      /* NOTE: this can sleep */
>
> There are no other calls to viport_disconnect() that I can see, so it
> can be made static (and the declaration in vnic_viport.h can be dropped).
> in fact given how small the function is and the fact that it has only a
> single call site, it might be easier just to merge it into
> viport_free().  But that's a matter of taste.
>
>  - R.
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
>
> To unsubscribe, please visit http://openib.org/mailman/listinfo/openib-general
>
