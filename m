From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Wed, 7 Dec 2011 15:04:56 +0000
Message-ID: <CAJSP0QUyx8tGxXG4ZFLHVTAout0zU4N9JaxSLucuD39P=5X6=w@mail.gmail.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
	<CAJSP0QXfHC8j2Kk9x6wyBMubo2=YvpaLAShJtwMWA2mtro6UhA@mail.gmail.com>
	<4EDDB71F.9080908@redhat.com>
	<CAJSP0QX5dDkpX+cRcQut2mb6K91zeqGLRrZBGAWT_r2p685gaQ@mail.gmail.com>
	<4EDDECA9.8060808@redhat.com>
	<CAJSP0QXsLwvH5xYj6h0E_V4VLg6DuUc-GKXu9esEYzL2MFcFGw@mail.gmail.com>
	<4EDED785.80804@redhat.com>
	<CAJSP0QUGWCf5WHEeCXzqZeF2CvpycxrGo-uPSfpWD1rWD3zeSg@mail.gmail.com>
	<4EDF57C7.90406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org, levinsasha928@gmail.com,
	bhutchings@solarflare.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4EDF57C7.90406@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 7, 2011 at 12:10 PM, Jason Wang <jasowang@redhat.com> wrote=
:
> On 12/07/2011 05:08 PM, Stefan Hajnoczi wrote:
> [...]
>
>>> > =A0Consider the complexity of the host nic each with their own st=
eering
>>> > =A0features, =A0this series make the first step with minimal effo=
rt to try
>>> > to let
>>> > =A0guest driver and host tap/macvtap co-operate like what physica=
l nic
>>> > does.
>>> > =A0There may be other method, but performance numbers is also nee=
ded to
>>> > give
>>> > =A0the answer.
>>
>> I agree that performance results for this need to be shown.
>>
>> My original point is really that it's not a good idea to take
>> individual steps without a good big picture because this will change
>> the virtio-net device specification. =A0If this turns out to be a de=
ad
>> end then hosts will need to continue to support the interface foreve=
r
>> (legacy guests could still try to use it). =A0So please first explai=
n
>> what the full stack picture is going to look like and how you think =
it
>> will lead to better performance. =A0You don't need to have all the c=
ode
>> or evidence, but just enough explanation so we see where this is all
>> going.
>
> I think I mention too little in the cover message.
>
> There's no much changes with Krishna's series except the method that
> choosing a rx virtqueue. Since original series use different hash met=
hods in
> host (rxhash) and guest (txhash), a different virtqueue were chose fo=
r a
> flow which could lead packets of a flow to be handled by different vh=
ost
> thread and vcpu. This may damage the performance.
>
> This series tries to let one vhost thread to process the packets of a=
 flow
> and also let the packets to be sent directly to a vcpu local to the t=
hread
> process the data. This is done by letting guest tell the desired queu=
e form
> which it want to receive the pakcet of a dedicated flow.
>
> So passing the hash from host to guest is needed to get the same hash=
 in the
> two sides. Then a guest programmable hash to queue table were introdu=
ced and
> guest co-operate with the host through accelerate RFS in guest.

Thanks for the context, that helps me understand it a little better.

Stefan
