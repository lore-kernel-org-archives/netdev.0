From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] 8 bytes kernel memory disclosure in AppleTalk getsockname.
Date: Wed, 26 Aug 2009 14:38:38 +0200
Message-ID: <4A952CCE.5050908@gmail.com>
References: <20090826111247.GA79673@clem1.netasq.com> <200908262101.DBJ57868.OHOFFVLQOtMFSJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: clement.lecigne@netasq.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932939AbZHZMim@vger.kernel.org>
In-Reply-To: <200908262101.DBJ57868.OHOFFVLQOtMFSJ@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa a =E9crit :
> Clement LECIGNE wrote:
>> Here is a patch that zero the whole sockaddr_at structure before
>> processing it. It should fix this bug.
>=20
> Same kind of bug at http://lkml.org/lkml/2006/7/25/51 .
> I wonder why not zero'ing sockaddr at the caller rather than
> zero'ing at individual ->getname(). Doing so will save some lines.
> --

It would not help zeroing buffer before calling ->getname(), since
getname() will overwrite it with a memcpy(buffer, &somestruct, sizeof(s=
omestruct));
