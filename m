From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Sun, 17 May 2015 09:27:35 +0300
Message-ID: <555834D7.5040807@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com> <5551A2CB.1010407@mellanox.com>
 <20150512185447.GA3503@obsidianresearch.com> <55532566.9040105@mellanox.com>
 <20150513165823.GA20343@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDC0C3@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FDC0C3-P5GAC/sN6hkd3b2yrw5b5LfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 15/05/2015 22:11, Hefty, Sean wrote:
>> The lifetime if each cm_id is clearly defined:
>>
>> cm_create_cm_id()
>> cm_ref_id() / cm_deref_id()
>> cm_destroy_id()
>>
>> The fact the CM might share a listen (and only a listen) ID behind the
>> scenes is not the caller's problem. That is an implementation choice,
>> each caller stands alone and uses the API properly, assuming it is the
>> only user of the returned cm_id.
> 
> Actually, I seriously question why the ib_cm should be modified at all for any of this.

At first I thought of doing all the changes in the rdma_cm module. After
a little thought though, I saw that this would require having a data
structure in rdma_cm that could tell which ib_cm_id to use when
listening on a new rdma_cm_id. That data structure would be indexed by a
service ID. This is exactly what the listen_service_table rb_tree in
ib_cm does, so instead of duplicating the rb_tree's data in another
module, I prefer to make a small change to ib_cm and let it continue
manage that tree.

Haggai

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
