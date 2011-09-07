From: Paul Menage <paul@paulmenage.org>
Subject: Re: [PATCH v2 2/9] Kernel Memory cgroup
Date: Tue, 6 Sep 2011 22:24:07 -0700
Message-ID: <CALdu-PCosvJ-SfVROLLM29RoMfxxRyW9E-_Za9A7LTAZwmkPeg@mail.gmail.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com> <1315369399-3073-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	containers@lists.osdl.org, netdev@vger.kernel.org,
	xemul@parallels.com, "David S. Miller" <davem@davemloft.net>,
	Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:54281 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432Ab1IGFY1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2011 01:24:27 -0400
In-Reply-To: <1315369399-3073-3-git-send-email-glommer@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2011 at 9:23 PM, Glauber Costa <glommer@parallels.com> w=
rote:
> +
> +struct kmem_cgroup {
> + =A0 =A0 =A0 struct cgroup_subsys_state css;
> + =A0 =A0 =A0 struct kmem_cgroup *parent;
> +};

There's a parent pointer in css.cgroup, so you shouldn't need a
separate one here.

Most cgroup subsystems define this structure (and the below accessor
functions) in their .c file rather than exposing it to the world? Does
this subsystem particularly need it exposed?

> +
> +static struct cgroup_subsys_state *kmem_create(
> + =A0 =A0 =A0 struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> + =A0 =A0 =A0 struct kmem_cgroup *sk =3D kzalloc(sizeof(*sk), GFP_KER=
NEL);

kcg or just cg would be a better name?

Paul
