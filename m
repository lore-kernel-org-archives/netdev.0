From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/3] fix error return code
Date: Fri, 17 Aug 2012 09:46:55 +0200
Message-ID: <1345189618-13758-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches fix cases where the return code appears to be unintentially
nonnegative.

The complete semantic match that finds the problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret,l;
expression e1,e2,e3;
statement S;
@@

if (ret < 0)
 { ... return ret; }
... when != ret = e1
    when forall
(
 goto l;
|
 return ...;
|
 if (<+... ret = e3 ...+>) S
|
*if(...)
 {
  ... when != ret = e2
* return ret;
}
)
// </smpl>
