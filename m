From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCHv4] virtio-spec: virtio network device multiqueue support
Date: Wed, 12 Sep 2012 07:38:06 -0700
Message-ID: <CA+mtBx_Kjp62UYJs-7OSFsFKndx6H1oOkuD8U3ooAUuR1PMF=Q@mail.gmail.com>
References: <20120909130308.GA3471@redhat.com> <878vcifwxi.fsf@rustcorp.com.au>
	<20120910061629.GC16819@redhat.com>
	<20120910062738.GA17331@redhat.com>
	<20120910063346.GA17338@redhat.com> <504DC831.1000709@redhat.com>
	<87har3dc4o.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3676898754626341326=="
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, rick.jones2@hp.com,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, pbonzini@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87har3dc4o.fsf@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============3676898754626341326==
Content-Type: multipart/alternative; boundary=14dae934086d96697e04c9822350

--14dae934086d96697e04c9822350
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Sep 11, 2012 at 10:49 PM, Rusty Russell <rusty@rustcorp.com.au>wrote:

> Jason Wang <jasowang@redhat.com> writes:
> > On 09/10/2012 02:33 PM, Michael S. Tsirkin wrote:
> >> A final addition: what you suggest above would be
> >> "TX follows RX", right?
>
> BTW, yes.  But it's a weird way to express what the nic is doing.
>
> >> It is in anticipation of something like that, that I made
> >> steering programming so generic.
>
> >> I think TX follows RX is more immediately useful for reasons above
> >> but we can add both to spec and let drivers and devices
> >> decide what they want to support.
>
> You mean "RX follows TX"?  ie. accelerated RFS.  I agree.
>
> RX following TX is logic of flow director I believe.  {a}RFS has RX follow
CPU where application receive is done on the socket.  So in RFS there is no
requirement to have a 1-1 correspondence between TX and RX queues, and in
fact this allows different number of queues between TX and RX.  We found
this necessary when using priority HW queues, so that there are more TX
queues than RX.

Perhaps Tom can explain how we avoid out-of-order receive for the
> accelerated RFS case?  It's not clear to me, but we need to be able to
> do that for virtio-net if it implements accelerated RFS.
>
> AFAIK ooo RX is possible with accelerated RFS.  We have an algorithm that
prevents this for RFS case by deferring a migration to a new queue as long
as it's possible that a flow might have outstanding packets on the old
queue.  I suppose this could be implemented in the device for the HW
queues, but I don't think it would be easy to cover all cases where packets
were already in transit to the host or other cases where host and device
queues are out of sync.


> > AFAIK, ixgbe does "rx follows tx". The only differences between ixgbe
> > and virtio-net is that ixgbe driver programs the flow director during
> > packet transmission but we suggest to do it silently in the device for
> > simplicity.
>
> Implying the receive queue by xmit will be slightly laggy.  Don't know
> if that's a problem.
>
> Cheers,
> Rusty.
>

--14dae934086d96697e04c9822350
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Sep 11, 2012 at 10:49 PM, Rusty =
Russell <span dir=3D"ltr">&lt;<a href=3D"mailto:rusty@rustcorp.com.au" targ=
et=3D"_blank">rusty@rustcorp.com.au</a>&gt;</span> wrote:<br><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;p=
adding-left:1ex">

<div>Jason Wang &lt;<a href=3D"mailto:jasowang@redhat.com" target=3D"_blank=
">jasowang@redhat.com</a>&gt; writes:<br>
&gt; On 09/10/2012 02:33 PM, Michael S. Tsirkin wrote:<br>
</div><div>&gt;&gt; A final addition: what you suggest above would be<br>
&gt;&gt; &quot;TX follows RX&quot;, right?<br>
<br>
</div>BTW, yes. =A0But it&#39;s a weird way to express what the nic is doin=
g.<br>
<div><br>
&gt;&gt; It is in anticipation of something like that, that I made<br>
&gt;&gt; steering programming so generic.<br>
<br>
&gt;&gt; I think TX follows RX is more immediately useful for reasons above=
<br>
&gt;&gt; but we can add both to spec and let drivers and devices<br>
&gt;&gt; decide what they want to support.<br>
<br>
</div>You mean &quot;RX follows TX&quot;? =A0ie. accelerated RFS. =A0I agre=
e.<br>
<br></blockquote><div>RX following TX is logic of flow director I believe. =
=A0{a}RFS has RX follow CPU where application receive is done on the socket=
. =A0So in RFS there is no requirement to have a 1-1 correspondence between=
 TX and RX queues, and in fact this allows different number of queues betwe=
en TX and RX. =A0We found this necessary when using priority HW queues, so =
that there are more TX queues than RX.</div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex">

Perhaps Tom can explain how we avoid out-of-order receive for the<br>
accelerated RFS case? =A0It&#39;s not clear to me, but we need to be able t=
o<br>
do that for virtio-net if it implements accelerated RFS.<br>
<div><br></div></blockquote><div>AFAIK ooo RX is possible with accelerated =
RFS. =A0We have an algorithm that prevents this for RFS case by deferring a=
 migration to a new queue as long as it&#39;s possible that a flow might ha=
ve outstanding packets on the old queue. =A0I suppose this could be impleme=
nted in the device for the HW queues, but I don&#39;t think it would be eas=
y to cover all cases where packets were already in transit to the host or o=
ther cases where host and device queues are out of sync.</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex"><div>
&gt; AFAIK, ixgbe does &quot;rx follows tx&quot;. The only differences betw=
een ixgbe<br>
&gt; and virtio-net is that ixgbe driver programs the flow director during<=
br>
&gt; packet transmission but we suggest to do it silently in the device for=
<br>
&gt; simplicity.<br>
<br>
</div>Implying the receive queue by xmit will be slightly laggy. =A0Don&#39=
;t know<br>
if that&#39;s a problem.<br>
<br>
Cheers,<br>
Rusty.<br>
</blockquote></div><br>

--14dae934086d96697e04c9822350--

--===============3676898754626341326==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============3676898754626341326==--
