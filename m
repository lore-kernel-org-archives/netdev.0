From: Marc Herbert <marc.herbert@free.fr>
Subject: Re: [PATCH 2.6] e100: use NAPI mode all the time (fwd)
Date: Tue, 8 Jun 2004 10:50:49 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0406072341430.2832@fcat>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Jun 2004, Scott Feldman wrote:

> I see no reason to keep the non-NAPI option for e100.  This patch remov=
es
> the CONFIG_E100_NAPI option and puts the driver in NAPI mode all the ti=
me.
> Matches the way tg3 works.
>
> Unless someone has a really good reason to keep the non-NAPI mode, this
> should go in for 2.6.7.

Scott,

 If I understand pre-NAPI history correctly (please anyone correct
me), the rationale/reason for the old, "backlog" SW FIFO design was to
cope with network bursts in the following context:

(1) transient network throughput higher than what the CPU could
    manage
(2) number of RxDescriptors (i.e., FIFO available to the NIC) too
    small to cope with this burst on the NIC.

Point (2) calls for freeing the NIC urgently, and point (1) calls for
_not_ processing each received packet all the way up immediatly with
an high priority, but doing a minimal amount of work instead, defering
the rest and quickly buffering the burst, hoping for quieter times
later. Thus the pre-NAPI intermediate backlog queue.

Removing some queue may remove the ability to cope with transient
bursts, if another queue is not able to fulfill the role of the
disappeared one.

Since you cannot make assumptions about the network/CPU balance
(people can stick any NICs in any machine they have, even old and slow
and overloaded ones) point (1) may still be true today. So the removal
of the non-API option for e100=A0assumes that point (2) is now always
false. That is: the RxDescriptors queue is big enough to cope with
transient network bursts; every e100 NIC can buffer these bursts by
itself without any help from the kernel backlog.

So two questions considering the point of view of non-NAPI e100 users
"forced" to migrate to NAPI

- for basic users, is the _default_  RxDescriptors "high enough",
  compared to the backlog dampering they were used to ?
- for advanced users, is the _maximum_ RxDescriptors "high enough"?
  compared to the backlog dampering they were used to ?


My 2 cents (you asked for them :-) Thanks in advance for pointing out
over-simplications above.


Marc.
