From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [RFC net-next 1/3] bonding: add infrastructure for an option API
Date: Fri, 10 Jan 2014 11:29:30 -0800
Message-ID: <A3A0930D-1C03-4C7E-91EE-A407FD3BF41F@cumulusnetworks.com>
References: <1389359495-9700-1-git-send-email-nikolay@redhat.com> <1389359495-9700-2-git-send-email-nikolay@redhat.com> <20140110111914.6b33b650@nehalam.linuxnetplumber.net>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:43688 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbaAJT3w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 14:29:52 -0500
In-Reply-To: <20140110111914.6b33b650@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 10, 2014, at 11:19 AM, Stephen Hemminger <stephen@networkplumber=
=2Eorg> wrote:

> On Fri, 10 Jan 2014 14:11:33 +0100
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
>=20
>> This patch adds the necessary basic infrastructure to support
>> centralized and unified option manipulation API for the bonding. The=
 new
>> structure bond_option will be used to describe each option with its
>> dependencies on modes which will be checked automatically thus remov=
ing a
>> lot of duplicated code. Also automatic range checking is added for
>> non-string options. Currently the option setting function requires R=
TNL to
>> be acquired prior to calling it, since many options already rely on =
RTNL
>> it seemed like the best choice to protect all against common race
>> conditions.
>=20
> Please add new features via netlink not sysfs.
> Sysfs is awkward API for command line, and not accessible through ip =
link.
> Also it provides no notification of changes or configuration back to =
switches
> and other things using netlink.

I don=92t think Nikolay is adding a new bonding feature.  This patch se=
ries is a (very nice!) cleanup of option handling in the bonding driver=
=2E  The recently added netlink interface to bonding options is still i=
ntact.  This patch moves all the parsing/setting/getting/locking/bounds=
_checking/dependency_checking into one nice clean API.

I=92m still reviewing patch set and might have more comments, but the f=
irst comment is: can this be generalized for more than just bonding?  I=
t seems lots of drivers which maintain an option set could benefit from=
 a similar API.

-scott