From: "DuBuisson, Thomas" <tmdubui@tycho.ncsc.mil>
Subject: PF_KEY not RCF2367 compliant
Date: Wed, 3 Aug 2005 11:47:44 -0400
Message-ID: <0D2F5426C26FD511A1C400B0D0D059680156922E@deliverance.tycho.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Section 3.1.6 of RFC 2367 clearly indicates there are two cases in which
user space programs can send the kernel PF_KEY messages.  The first case is
just the 'struct sadb_msg' header that should specify an error relating to a
previous acquire message.  I don't think the other case is implemented in
the Linux kernel - I have reprinted the relevant portion of the RFC below:

------------------
   The third is where an application-layer consumer of security
   associations (e.g.  an OSPFv2 or RIPv2 daemon) needs a security
   association.

        Send an SADB_ACQUIRE message from a user process to the kernel.

        <base, address(SD), (address(P),) (identity(SD),) (sensitivity,)
          proposal>

        The kernel returns an SADB_ACQUIRE message to registered
          sockets.

        <base, address(SD), (address(P),) (identity(SD),) (sensitivity,)
          proposal>

        The user-level consumer waits for an SADB_UPDATE or SADB_ADD
        message for its particular type, and then can use that
        association by using SADB_GET messages.
----------

Now for the barrage of questions:
Was this omitted for a reason?
Are we aware this was omitted?
Does someone already have a patch?
Would a patch be accepted for 2.6.13 if it is sent in time?  This is a bug
after all.

Cheers,
Thomas
