From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: TGe overview #3
Date: Mon, 2 Aug 2004 22:38:57 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408022239.04871.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6500354.cgk6mvoYQD";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart6500354.cgk6mvoYQD
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46inally, let's review Traffic Streams.

There are 2 different concepts: logical layer (admission) and completely ne=
w=20
media access mechanism HCCA (Hybrid Coordinator Channel Access).

Idea behind HCCA is similar to PCF (Point Coordinator Function) from old=20
802.11 standard. Hybrid Coordinator (HC), which have to be AP, decides who=
=20
will talk when.

Technically it is implemented as following:
All time divided into contention based (EDCA TXOP's) and contention free CA=
P=20
(Controlled AccessPhase). When HC want to start CAP, it simply starts it=20
after PIFS interval of idle media. PIFS is shorter then any interval betwee=
n=20
EDCA frame exchange sequences, thus HC will preempt any EDCA flow at his=20
will. Then, HC can either transmit frames, or it may send Contention Free=20
Poll (CFP) frame to some STA. This frame gives to the STA "polled" TXOP, in=
=20
contrast with EDCA TXOP. CFP frame provides TXOP duration.

Now, admission control. For HCCA it is the only mechanism. But, admission=20
control may be activated also for 2 high priority EDCA categories.

=46or EDCA it mean the following: one can't use these categories as it was=
=20
described in EDCA, instead, TID should be obtained. For EDCA this mechanism=
=20
used to control bandwidth allocation. But remember, EDCA is contention base=
d=20
policy, without any guarantee.

TID's 8-15 dedicates to TS (Traffic Streams). In order to obtain TID, STA=20
should send request to AP. Corresponded frame called ADDTS, it contain=20
traffic specification: requested bandwidth, delay, periodicity, frame size=
=20
etc. AP may accept or decline this request. It may also come with counter=20
proposal with different parameters.

TS may be up-stream, down-stream, or bi-direction

If TS accepted by AP, AP provides schedule information. This information=20
consist of Service Interval (SI) - interval between successive Service=20
Periods (SP), during which AP serves this TS, and Start Time.
Start time have the following meaning: STA may request exact timing in ADDT=
S=20
request. In this case, it will be served at precise times StartTime+n*SI.=20
This used for power save: STA may identify itself as power down, but wake u=
p=20
for its stream. Obvious usage is .11 phones.

Here, important QoS related part is:
AP admin decides upon admission control policy. For "legacy stations", that=
=20
don't speak TS (stations implementing WME spec), it may provide only 2 low=
=20
priority access categories. These STA will be severely impacted in=20
performance.
STA have to know TGE in order to get real performance. And, STA need to kno=
w=20
how to identify streams (RSVP like).

One additional feature: DLP (Direct Link Protocol). Unrelated to anything=20
else. Idea is to let 2 stations to talk directly. Link establishment is=20
through AP, but later they send frames directly, reducing media time 2x. Th=
is=20
is important for applications like streaming of high definition TV, for whi=
ch=20
"usual" way when AP forward frames, is unacceptable.

P.S. I did not covered many other stuff which is not related directly to Qo=
S.

--nextPart6500354.cgk6mvoYQD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBBDphYqxdj7mhC6o0RAmzAAKCFDMlYn7QuujVswZshlWPTZehMMQCgpXEw
7UWwHkUzYOgsx0c61i82UpU=
=QGXS
-----END PGP SIGNATURE-----

--nextPart6500354.cgk6mvoYQD--
